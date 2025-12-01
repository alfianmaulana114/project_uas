-- Setup tabel reward_items dan reward_redemptions untuk sistem penukaran poin
-- Jalankan script ini di Supabase SQL Editor

BEGIN;

-- Tabel reward_items: menyimpan reward yang bisa ditukar dengan poin
CREATE TABLE IF NOT EXISTS public.reward_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('voucher', 'hadiah')),
  points_required INTEGER NOT NULL CHECK (points_required > 0),
  stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
  image_url TEXT,
  icon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabel reward_redemptions: menyimpan history penukaran reward
CREATE TABLE IF NOT EXISTS public.reward_redemptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reward_item_id UUID NOT NULL REFERENCES public.reward_items(id) ON DELETE CASCADE,
  reward_name TEXT NOT NULL, -- Denormalized untuk history
  points_used INTEGER NOT NULL CHECK (points_used > 0),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'cancelled')),
  redeemed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Index untuk performa query
CREATE INDEX IF NOT EXISTS idx_reward_items_category ON public.reward_items(category);
CREATE INDEX IF NOT EXISTS idx_reward_items_stock ON public.reward_items(stock);
CREATE INDEX IF NOT EXISTS idx_reward_redemptions_user ON public.reward_redemptions(user_id);
CREATE INDEX IF NOT EXISTS idx_reward_redemptions_status ON public.reward_redemptions(status);
CREATE INDEX IF NOT EXISTS idx_reward_redemptions_redeemed_at ON public.reward_redemptions(redeemed_at DESC);

-- Trigger untuk update updated_at
CREATE OR REPLACE FUNCTION public.update_reward_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_reward_items_updated_at ON public.reward_items;
CREATE TRIGGER trg_reward_items_updated_at
  BEFORE UPDATE ON public.reward_items
  FOR EACH ROW
  EXECUTE FUNCTION public.update_reward_items_updated_at();

-- RLS Policies
ALTER TABLE public.reward_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_redemptions ENABLE ROW LEVEL SECURITY;

-- Policy: Semua user bisa lihat reward items
DROP POLICY IF EXISTS reward_items_select_all ON public.reward_items;
CREATE POLICY reward_items_select_all ON public.reward_items
  FOR SELECT TO public USING (true);

-- Policy: User hanya bisa lihat redemption milik sendiri
DROP POLICY IF EXISTS reward_redemptions_select_own ON public.reward_redemptions;
CREATE POLICY reward_redemptions_select_own ON public.reward_redemptions
  FOR SELECT TO public USING (auth.uid() = user_id);

-- Policy: User bisa insert redemption milik sendiri
DROP POLICY IF EXISTS reward_redemptions_insert_own ON public.reward_redemptions;
CREATE POLICY reward_redemptions_insert_own ON public.reward_redemptions
  FOR INSERT TO public WITH CHECK (auth.uid() = user_id);

-- RPC Function: Redeem reward (menukar poin dengan reward)
CREATE OR REPLACE FUNCTION public.rpc_redeem_reward(
  p_reward_item_id UUID
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_reward public.reward_items%ROWTYPE;
  v_user public.users%ROWTYPE;
  v_redemption_id UUID;
  v_new_points INTEGER;
BEGIN
  -- Validasi user login
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized' USING ERRCODE = 'P0001';
  END IF;

  -- Ambil data reward
  SELECT * INTO v_reward
  FROM public.reward_items
  WHERE id = p_reward_item_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Reward tidak ditemukan' USING ERRCODE = 'P0001';
  END IF;

  -- Validasi stok
  IF v_reward.stock <= 0 THEN
    RAISE EXCEPTION 'Stok reward habis' USING ERRCODE = 'P0001';
  END IF;

  -- Ambil data user
  SELECT * INTO v_user
  FROM public.users
  WHERE id = v_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'User tidak ditemukan' USING ERRCODE = 'P0001';
  END IF;

  -- Validasi poin cukup
  IF COALESCE(v_user.total_points, 0) < v_reward.points_required THEN
    RAISE EXCEPTION 'Poin tidak cukup. Dibutuhkan % poin, Anda memiliki % poin', 
      v_reward.points_required, COALESCE(v_user.total_points, 0) USING ERRCODE = 'P0001';
  END IF;

  -- Kurangi poin user
  v_new_points := COALESCE(v_user.total_points, 0) - v_reward.points_required;
  UPDATE public.users
  SET total_points = v_new_points
  WHERE id = v_user_id
  RETURNING * INTO v_user;

  -- Kurangi stok reward
  UPDATE public.reward_items
  SET stock = stock - 1
  WHERE id = p_reward_item_id
  RETURNING * INTO v_reward;

  -- Buat record redemption
  INSERT INTO public.reward_redemptions (
    user_id,
    reward_item_id,
    reward_name,
    points_used,
    status
  )
  VALUES (
    v_user_id,
    p_reward_item_id,
    v_reward.name,
    v_reward.points_required,
    'completed'
  )
  RETURNING id INTO v_redemption_id;

  -- Update completed_at untuk status completed
  UPDATE public.reward_redemptions
  SET completed_at = now()
  WHERE id = v_redemption_id;

  -- Return hasil
  RETURN jsonb_build_object(
    'success', true,
    'redemption_id', v_redemption_id,
    'reward_name', v_reward.name,
    'points_used', v_reward.points_required,
    'remaining_points', v_new_points,
    'remaining_stock', v_reward.stock
  );
END;
$$;

-- RPC Function: Get all reward items
CREATE OR REPLACE FUNCTION public.rpc_get_all_reward_items(
  p_category TEXT DEFAULT NULL
)
RETURNS SETOF public.reward_items
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF p_category IS NULL OR p_category = '' THEN
    RETURN QUERY
    SELECT * FROM public.reward_items
    ORDER BY points_required ASC, name ASC;
  ELSE
    RETURN QUERY
    SELECT * FROM public.reward_items
    WHERE category = p_category
    ORDER BY points_required ASC, name ASC;
  END IF;
END;
$$;

-- RPC Function: Get user redemptions
CREATE OR REPLACE FUNCTION public.rpc_get_user_redemptions(
  p_limit INTEGER DEFAULT 50
)
RETURNS SETOF public.reward_redemptions
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID := auth.uid();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized' USING ERRCODE = 'P0001';
  END IF;

  RETURN QUERY
  SELECT * FROM public.reward_redemptions
  WHERE user_id = v_user_id
  ORDER BY redeemed_at DESC
  LIMIT p_limit;
END;
$$;

-- RPC Function: Add points to user (untuk testing atau bonus)
CREATE OR REPLACE FUNCTION public.rpc_add_points(
  p_points INTEGER
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_user public.users%ROWTYPE;
  v_new_points INTEGER;
BEGIN
  -- Validasi user login
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized' USING ERRCODE = 'P0001';
  END IF;

  -- Validasi points positif
  IF p_points <= 0 THEN
    RAISE EXCEPTION 'Poin harus lebih dari 0' USING ERRCODE = 'P0001';
  END IF;

  -- Ambil data user
  SELECT * INTO v_user
  FROM public.users
  WHERE id = v_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'User tidak ditemukan' USING ERRCODE = 'P0001';
  END IF;

  -- Tambah poin
  v_new_points := COALESCE(v_user.total_points, 0) + p_points;
  UPDATE public.users
  SET total_points = v_new_points
  WHERE id = v_user_id
  RETURNING * INTO v_user;

  -- Return hasil
  RETURN jsonb_build_object(
    'success', true,
    'points_added', p_points,
    'previous_points', COALESCE(v_user.total_points - p_points, 0),
    'new_points', v_new_points
  );
END;
$$;

-- Seed data: contoh reward items
INSERT INTO public.reward_items (name, description, category, points_required, stock, icon)
VALUES
  -- Voucher (Poin Rendah - Menengah)
  ('E-Wallet OVO Rp 20.000', 'Saldo OVO senilai Rp 20.000', 'voucher', 200, 30, 'account_balance_wallet'),
  ('Pulsa Rp 25.000', 'Pulsa untuk semua operator', 'voucher', 250, 25, 'phone_android'),
  ('Voucher Grab Food Rp 30.000', 'Voucher untuk pesan makanan via Grab Food', 'voucher', 300, 20, 'restaurant'),
  ('Voucher Gojek Rp 50.000', 'Voucher untuk layanan Gojek', 'voucher', 500, 15, 'directions_car'),
  ('Voucher Starbucks Rp 50.000', 'Voucher belanja di Starbucks senilai Rp 50.000', 'voucher', 500, 10, 'local_cafe'),
  ('E-Wallet DANA Rp 50.000', 'Saldo DANA senilai Rp 50.000', 'voucher', 500, 20, 'account_balance_wallet'),
  ('Voucher Shopee Rp 75.000', 'Voucher belanja di Shopee', 'voucher', 750, 8, 'shopping_cart'),
  ('Voucher Tokopedia Rp 100.000', 'Voucher belanja online di Tokopedia', 'voucher', 1000, 5, 'shopping_bag'),
  ('Voucher Traveloka Rp 150.000', 'Voucher untuk booking hotel dan tiket pesawat', 'voucher', 1500, 5, 'flight'),
  ('Voucher Netflix 1 Bulan', 'Voucher langganan Netflix Premium selama 1 bulan', 'voucher', 2000, 3, 'movie'),
  ('Voucher Spotify Premium 3 Bulan', 'Voucher langganan Spotify Premium selama 3 bulan', 'voucher', 2500, 3, 'headphones'),
  
  -- Hadiah Fisik (Poin Menengah - Tinggi)
  ('Tumbler Stainless Steel', 'Tumbler stainless steel berkualitas tinggi dengan desain modern', 'hadiah', 500, 15, 'water_drop'),
  ('Power Bank 10000mAh', 'Power bank portable dengan kapasitas 10000mAh, fast charging', 'hadiah', 800, 12, 'battery_charging_full'),
  ('Mouse Wireless', 'Mouse wireless ergonomis dengan sensor presisi tinggi', 'hadiah', 1000, 10, 'mouse'),
  ('Keyboard Mechanical RGB', 'Keyboard mechanical dengan backlight RGB dan switch berkualitas', 'hadiah', 1500, 8, 'keyboard'),
  ('Headphone Bluetooth', 'Headphone wireless dengan noise cancellation dan kualitas suara premium', 'hadiah', 2000, 6, 'headphones'),
  ('Smart Watch', 'Smartwatch dengan fitur fitness tracking, heart rate monitor, dan notifikasi', 'hadiah', 3000, 5, 'watch'),
  ('Webcam HD 1080p', 'Webcam HD dengan auto-focus dan microphone built-in untuk meeting online', 'hadiah', 2500, 7, 'videocam'),
  ('Speaker Bluetooth Portable', 'Speaker Bluetooth dengan bass boost dan waterproof IPX7', 'hadiah', 1800, 8, 'speaker'),
  ('Laptop Stand Aluminium', 'Laptop stand ergonomis dari aluminium untuk meningkatkan produktivitas', 'hadiah', 1200, 10, 'laptop'),
  ('Mechanical Keyboard Premium', 'Keyboard mechanical premium dengan keycaps PBT dan switch Cherry MX', 'hadiah', 4000, 4, 'keyboard'),
  ('Monitor 24 inch Full HD', 'Monitor LED 24 inch Full HD dengan refresh rate 75Hz untuk produktivitas', 'hadiah', 5000, 3, 'monitor'),
  ('Gaming Chair Ergonomic', 'Gaming chair ergonomis dengan lumbar support dan adjustable height', 'hadiah', 4500, 3, 'chair')
ON CONFLICT DO NOTHING;

COMMIT;

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

