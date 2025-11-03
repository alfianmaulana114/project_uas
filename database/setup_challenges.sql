-- Supabase Challenges Feature Setup
-- Types, Tables, Indexes, Policies, Triggers, RPC, View, and Seeds

-- Extensions (ensure pgcrypto for gen_random_uuid)
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enums
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'challenge_category') THEN
    CREATE TYPE challenge_category AS ENUM (
      'social_media',
      'olahraga',
      'bersosialisasi',
      'membaca_buku'
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'challenge_status') THEN
    CREATE TYPE challenge_status AS ENUM ('active', 'completed', 'cancelled');
  END IF;
END$$;

-- ============================================
-- Upgrade path: jika tabel sudah ada tanpa kolom yang dibutuhkan
-- ============================================

-- challenges: tambah kolom category jika belum ada
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'challenges'
  ) THEN
    BEGIN
      ALTER TABLE public.challenges
        ADD COLUMN IF NOT EXISTS category challenge_category,
        ADD COLUMN IF NOT EXISTS icon VARCHAR(50);
    EXCEPTION WHEN duplicate_column THEN NULL; END;

    -- Jika kolom category sudah ada tapi bertipe berbeda (mis. varchar), konversi ke enum
    BEGIN
      ALTER TABLE public.challenges
        ALTER COLUMN category TYPE challenge_category USING category::challenge_category;
    EXCEPTION WHEN others THEN NULL; END;

    -- Set default category untuk row lama yang masih NULL (pakai cast enum)
    UPDATE public.challenges SET category = 'social_media'::challenge_category
    WHERE category IS NULL;

    -- Jadikan NOT NULL
    BEGIN
      ALTER TABLE public.challenges
        ALTER COLUMN category SET NOT NULL;
    EXCEPTION WHEN others THEN NULL; END;
  END IF;
END$$;

-- user_challenges: tambah kolom category/book_name/event_name jika belum ada
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'user_challenges'
  ) THEN
    BEGIN
      ALTER TABLE public.user_challenges
        ADD COLUMN IF NOT EXISTS category challenge_category,
        ADD COLUMN IF NOT EXISTS book_name TEXT,
        ADD COLUMN IF NOT EXISTS event_name TEXT;
    EXCEPTION WHEN duplicate_column THEN NULL; END;

    -- Jika kolom category sudah ada tapi bertipe berbeda (mis. varchar), konversi ke enum
    BEGIN
      ALTER TABLE public.user_challenges
        ALTER COLUMN category TYPE challenge_category USING category::challenge_category;
    EXCEPTION WHEN others THEN NULL; END;

    -- Backfill category dari master challenges jika NULL
    UPDATE public.user_challenges uc
    SET category = (c.category)::challenge_category
    FROM public.challenges c
    WHERE uc.challenge_id = c.id AND uc.category IS NULL;

    -- Kalau masih NULL (data orphan), set default aman
    UPDATE public.user_challenges SET category = 'social_media'::challenge_category
    WHERE category IS NULL;

    -- Jadikan NOT NULL
    BEGIN
      ALTER TABLE public.user_challenges
        ALTER COLUMN category SET NOT NULL;
    EXCEPTION WHEN others THEN NULL; END;
  END IF;
END$$;

-- Master table
CREATE TABLE IF NOT EXISTS public.challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_name VARCHAR(100) NOT NULL,
  description TEXT,
  duration_days INTEGER NOT NULL CHECK (duration_days > 0),
  points_reward INTEGER CHECK (points_reward >= 0),
  icon VARCHAR(50),
  category challenge_category NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_challenges_name_per_category
  ON public.challenges (category, challenge_name);

CREATE INDEX IF NOT EXISTS idx_challenges_category
  ON public.challenges (category);

-- User challenges
CREATE TABLE IF NOT EXISTS public.user_challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  challenge_id UUID NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  category challenge_category NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  status challenge_status NOT NULL DEFAULT 'active',
  current_day INTEGER NOT NULL DEFAULT 1 CHECK (current_day >= 1),
  success_days INTEGER NOT NULL DEFAULT 0 CHECK (success_days >= 0),
  points_earned INTEGER NOT NULL DEFAULT 0 CHECK (points_earned >= 0),
  book_name TEXT,
  event_name TEXT,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  CONSTRAINT chk_book_name_required
    CHECK (category <> 'membaca_buku' OR (book_name IS NOT NULL AND length(trim(book_name)) > 0)),
  CONSTRAINT chk_event_name_required
    CHECK (category <> 'bersosialisasi' OR (event_name IS NOT NULL AND length(trim(event_name)) > 0))
);

CREATE INDEX IF NOT EXISTS idx_user_challenges_user
  ON public.user_challenges (user_id);

CREATE INDEX IF NOT EXISTS idx_user_challenges_status
  ON public.user_challenges (status);

CREATE INDEX IF NOT EXISTS idx_user_challenges_user_category
  ON public.user_challenges (user_id, category);

-- Prevent >1 active per category per user
CREATE UNIQUE INDEX IF NOT EXISTS uq_active_category_per_user
  ON public.user_challenges (user_id, category)
  WHERE status = 'active';

-- Trigger to set defaults from master
CREATE OR REPLACE FUNCTION public.fn_user_challenges_set_defaults()
RETURNS TRIGGER AS $$
DECLARE
  ch RECORD;
BEGIN
  SELECT category, duration_days INTO ch
  FROM public.challenges WHERE id = NEW.challenge_id;

  IF ch IS NULL THEN
    RAISE EXCEPTION 'Challenge % tidak ditemukan', NEW.challenge_id;
  END IF;

  NEW.category := ch.category;

  IF NEW.end_date IS NULL THEN
    NEW.end_date := NEW.start_date + (ch.duration_days - 1);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_user_challenges_set_defaults ON public.user_challenges;
CREATE TRIGGER trg_user_challenges_set_defaults
BEFORE INSERT OR UPDATE OF challenge_id, start_date
ON public.user_challenges
FOR EACH ROW
EXECUTE FUNCTION public.fn_user_challenges_set_defaults();

-- RLS Policies
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'challenges' AND policyname = 'challenges_select_all'
  ) THEN
    CREATE POLICY challenges_select_all ON public.challenges FOR SELECT TO public USING (true);
  END IF;
END$$;

ALTER TABLE public.user_challenges ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='user_challenges' AND policyname='user_challenges_select_own'
  ) THEN
    CREATE POLICY user_challenges_select_own ON public.user_challenges FOR SELECT TO authenticated USING (user_id = auth.uid());
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='user_challenges' AND policyname='user_challenges_insert_own'
  ) THEN
    CREATE POLICY user_challenges_insert_own ON public.user_challenges FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='user_challenges' AND policyname='user_challenges_update_own'
  ) THEN
    CREATE POLICY user_challenges_update_own ON public.user_challenges FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='user_challenges' AND policyname='user_challenges_delete_own'
  ) THEN
    CREATE POLICY user_challenges_delete_own ON public.user_challenges FOR DELETE TO authenticated USING (user_id = auth.uid());
  END IF;
END$$;

-- RPCs
CREATE OR REPLACE FUNCTION public.rpc_start_challenge(
  p_challenge_id UUID,
  p_start_date DATE DEFAULT CURRENT_DATE,
  p_book_name TEXT DEFAULT NULL,
  p_event_name TEXT DEFAULT NULL
)
RETURNS public.user_challenges
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_challenge RECORD;
  v_row public.user_challenges;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT id, category, duration_days INTO v_challenge
  FROM public.challenges WHERE id = p_challenge_id;

  IF v_challenge.id IS NULL THEN
    RAISE EXCEPTION 'Challenge tidak ditemukan';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.user_challenges
    WHERE user_id = v_user_id AND category = v_challenge.category AND status = 'active'
  ) THEN
    RAISE EXCEPTION 'Anda sudah memiliki challenge aktif pada kategori %', v_challenge.category;
  END IF;

  INSERT INTO public.user_challenges (
    user_id, challenge_id, category, start_date, end_date, status, book_name, event_name
  )
  VALUES (
    v_user_id, p_challenge_id, v_challenge.category,
    p_start_date, p_start_date + (v_challenge.duration_days - 1), 'active',
    p_book_name, p_event_name
  ) RETURNING * INTO v_row;

  RETURN v_row;
END;
$$;

CREATE OR REPLACE FUNCTION public.rpc_get_all_challenges(
  p_category public.challenge_category DEFAULT NULL
)
RETURNS SETOF public.challenges
LANGUAGE sql STABLE AS $$
  SELECT * FROM public.challenges
  WHERE (p_category IS NULL OR category::text = p_category::text)
  ORDER BY category, challenge_name;
$$;

CREATE OR REPLACE FUNCTION public.rpc_get_active_user_challenges(
  p_category public.challenge_category DEFAULT NULL
)
RETURNS SETOF public.user_challenges
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT uc.* FROM public.user_challenges uc
  WHERE uc.user_id = auth.uid() AND uc.status = 'active'
    AND (p_category IS NULL OR uc.category::text = p_category::text)
  ORDER BY uc.created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.rpc_log_daily_progress(
  p_user_challenge_id UUID,
  p_success BOOLEAN
)
RETURNS public.user_challenges
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_uc public.user_challenges;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'Unauthorized'; END IF;

  SELECT * INTO v_uc FROM public.user_challenges
  WHERE id = p_user_challenge_id AND user_id = v_user_id AND status = 'active'
  FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'Challenge tidak ditemukan/aktif untuk user'; END IF;

  UPDATE public.user_challenges
  SET
    current_day = LEAST(current_day + 1, EXTRACT(DAY FROM (end_date - start_date + 1))::int),
    success_days = success_days + CASE WHEN p_success THEN 1 ELSE 0 END,
    completed_at = CASE WHEN (current_day + 1) >= EXTRACT(DAY FROM (end_date - start_date + 1))::int THEN now() ELSE completed_at END,
    status = CASE WHEN (current_day + 1) >= EXTRACT(DAY FROM (end_date - start_date + 1))::int THEN 'completed' ELSE status END
  WHERE id = p_user_challenge_id
  RETURNING * INTO v_uc;

  RETURN v_uc;
END;
$$;

-- View for progress percent
CREATE OR REPLACE VIEW public.v_user_challenge_progress AS
SELECT
  uc.id,
  uc.user_id,
  uc.challenge_id,
  uc.category,
  uc.status,
  uc.start_date,
  uc.end_date,
  uc.current_day,
  GREATEST(1, (uc.end_date - uc.start_date + 1))::int AS total_days,
  ROUND(LEAST(100, (uc.current_day::numeric / GREATEST(1, (uc.end_date - uc.start_date + 1))::numeric) * 100), 2) AS progress_percent,
  uc.success_days,
  uc.points_earned,
  uc.book_name,
  uc.event_name,
  uc.created_at
FROM public.user_challenges uc;

-- Seeds: 3 per category
INSERT INTO public.challenges (challenge_name, description, duration_days, points_reward, icon, category)
SELECT * FROM (VALUES
  ('Detox Sosmed 7 Hari', 'Kurangi waktu media sosial maksimum 30 menit/hari', 7, 70, 'phone_off', 'social_media'),
  ('Tanpa Notifikasi 14 Hari', 'Matikan notifikasi non-esensial', 14, 140, 'notifications_off', 'social_media'),
  ('Screen-free Pagi', 'Tanpa layar 1 jam setelah bangun', 10, 100, 'sun', 'social_media'),

  ('Jalan Pagi 15 Menit', 'Berjalan minimal 15 menit setiap hari', 10, 120, 'directions_walk', 'olahraga'),
  ('Push-up Harian', 'Minimal 20 push-up/hari', 7, 90, 'fitness_center', 'olahraga'),
  ('Yoga 10 Hari', 'Sesi yoga 20 menit/hari', 10, 150, 'self_improvement', 'olahraga'),

  ('Sapa Teman Lama', 'Kontak teman lama setidaknya 3 kali', 7, 80, 'chat', 'bersosialisasi'),
  ('Hadiri Komunitas', 'Ikut 1 kegiatan komunitas', 14, 160, 'groups', 'bersosialisasi'),
  ('Quality Talk', 'Percakapan mendalam 20 menit, 5 kali', 10, 140, 'record_voice_over', 'bersosialisasi'),

  ('Baca 10 Halaman/Hari', 'Minimal 10 halaman tiap hari', 10, 120, 'menu_book', 'membaca_buku'),
  ('Selesai 1 Buku', 'Tuntaskan 1 buku', 14, 200, 'book', 'membaca_buku'),
  ('Ringkas Bacaan', 'Tulis ringkasan singkat tiap sesi', 7, 100, 'summarize', 'membaca_buku')
) AS s(challenge_name, description, duration_days, points_reward, icon, category)
WHERE NOT EXISTS (
  SELECT 1 FROM public.challenges c
  WHERE c.challenge_name = s.challenge_name AND c.category = s.category
);


