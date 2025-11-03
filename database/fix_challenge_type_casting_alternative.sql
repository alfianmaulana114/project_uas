-- Fix Challenge Type Casting Issues - Alternative Solution
-- Masalah: Error "operator does not exist: character varying = challenge_category"
-- Solusi: Gunakan explicit cast di semua comparison dan INSERT

-- Fix rpc_start_challenge: gunakan explicit cast di semua tempat
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
  v_category_enum public.challenge_category;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  -- Ambil challenge - category sudah enum dari tabel challenges
  SELECT id, category, duration_days INTO v_challenge
  FROM public.challenges WHERE id = p_challenge_id;

  IF v_challenge.id IS NULL THEN
    RAISE EXCEPTION 'Challenge tidak ditemukan';
  END IF;

  -- Assign category (sudah enum)
  v_category_enum := v_challenge.category;

  -- Fix: Compare dengan explicit cast untuk memastikan type safety
  -- Cast category di user_challenges ke text, lalu compare dengan text dari enum
  IF EXISTS (
    SELECT 1 FROM public.user_challenges
    WHERE user_id = v_user_id 
      AND category::text = v_category_enum::text  -- Compare sebagai text untuk avoid type mismatch
      AND status = 'active'
  ) THEN
    RAISE EXCEPTION 'Anda sudah memiliki challenge aktif pada kategori %', v_category_enum::text;
  END IF;

  -- INSERT tanpa set category, biarkan trigger fn_user_challenges_set_defaults yang mengatur
  -- Trigger akan set category dari challenge master dengan type yang benar
  INSERT INTO public.user_challenges (
    user_id, challenge_id, start_date, end_date, status, book_name, event_name
  )
  VALUES (
    v_user_id, 
    p_challenge_id, 
    p_start_date, 
    p_start_date + (v_challenge.duration_days - 1), 
    'active',
    p_book_name, 
    p_event_name
  ) RETURNING * INTO v_row;

  RETURN v_row;
END;
$$;

