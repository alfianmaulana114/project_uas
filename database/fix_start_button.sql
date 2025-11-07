-- Fix Start Button: resolve 42883 (challenge_category = character varying)
-- Safe to run on existing database. Copy all to Supabase SQL Editor and Run.

BEGIN;

-- Ensure enums exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'challenge_category') THEN
    CREATE TYPE challenge_category AS ENUM ('social_media','olahraga','bersosialisasi','membaca_buku');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'challenge_status') THEN
    CREATE TYPE challenge_status AS ENUM ('active','completed','cancelled');
  END IF;
END$$;

-- Drop view first to allow column type changes if needed
DROP VIEW IF EXISTS public.v_user_challenge_progress;

-- Drop defaults to allow enum conversion
ALTER TABLE public.challenges
  ALTER COLUMN category DROP DEFAULT;

ALTER TABLE public.user_challenges
  ALTER COLUMN category DROP DEFAULT;

ALTER TABLE public.user_challenges
  ALTER COLUMN status DROP DEFAULT;

-- Force column types to enum (casts existing values)
ALTER TABLE public.challenges
  ALTER COLUMN category TYPE challenge_category
  USING category::challenge_category;

ALTER TABLE public.user_challenges
  ALTER COLUMN category TYPE challenge_category
  USING category::challenge_category;

-- Optional: align status to enum if possible (ignore errors)
DO $$
BEGIN
  BEGIN
    ALTER TABLE public.user_challenges
      ALTER COLUMN status TYPE challenge_status
      USING status::challenge_status;
  EXCEPTION WHEN others THEN NULL; END;
END$$;

-- Recreate CHECK constraints with explicit enum casts
ALTER TABLE public.user_challenges DROP CONSTRAINT IF EXISTS chk_book_name_required;
ALTER TABLE public.user_challenges DROP CONSTRAINT IF EXISTS chk_event_name_required;

ALTER TABLE public.user_challenges
  ADD CONSTRAINT chk_book_name_required
  CHECK (
    category <> 'membaca_buku'::challenge_category
    OR (book_name IS NOT NULL AND length(trim(book_name)) > 0)
  );

ALTER TABLE public.user_challenges
  ADD CONSTRAINT chk_event_name_required
  CHECK (
    category <> 'bersosialisasi'::challenge_category
    OR (event_name IS NOT NULL AND length(trim(event_name)) > 0)
  );

-- Robust rpc_start_challenge: compare category as text to avoid enum-varchar mismatch
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
  v_ch public.challenges%ROWTYPE;
  v_row public.user_challenges;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT * INTO v_ch FROM public.challenges WHERE id = p_challenge_id;
  IF v_ch.id IS NULL THEN
    RAISE EXCEPTION 'Challenge tidak ditemukan';
  END IF;

  -- Prevent >1 active in same category per user
  IF EXISTS (
    SELECT 1 FROM public.user_challenges
    WHERE user_id = v_user_id
      AND status = 'active'
      AND category::text = v_ch.category::text
  ) THEN
    RAISE EXCEPTION 'Anda sudah memiliki challenge aktif pada kategori %', v_ch.category;
  END IF;

  INSERT INTO public.user_challenges (
    user_id, challenge_id, category, start_date, end_date, status, book_name, event_name
  )
  VALUES (
    v_user_id, p_challenge_id, v_ch.category,
    p_start_date, p_start_date + (v_ch.duration_days - 1), 'active',
    p_book_name, p_event_name
  )
  RETURNING * INTO v_row;

  RETURN v_row;
END;
$$;

-- Recreate view
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

COMMIT;

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- Verification helpers (optional)
-- SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid='public.user_challenges'::regclass ORDER BY conname;
-- SELECT table_name, column_name, data_type, udt_name FROM information_schema.columns WHERE table_schema='public' AND table_name IN ('challenges','user_challenges') AND column_name IN ('category','status') ORDER BY table_name, column_name;
-- SELECT * FROM public.v_user_challenge_progress WHERE status = 'active' ORDER BY created_at DESC;