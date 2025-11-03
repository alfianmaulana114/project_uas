-- Rollback Challenge Fixes - Kembalikan ke Versi Original
-- Gunakan script ini jika ada masalah setelah fix_challenge_type_casting.sql
-- Script ini akan mengembalikan semua function ke versi original dari setup_challenges.sql

-- Kembalikan rpc_start_challenge ke versi original
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

-- Kembalikan rpc_get_all_challenges ke versi original
CREATE OR REPLACE FUNCTION public.rpc_get_all_challenges(
  p_category public.challenge_category DEFAULT NULL
)
RETURNS SETOF public.challenges
LANGUAGE sql STABLE AS $$
  SELECT * FROM public.challenges
  WHERE (p_category IS NULL OR category::text = p_category::text)
  ORDER BY category, challenge_name;
$$;

-- Kembalikan rpc_get_active_user_challenges ke versi original
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

