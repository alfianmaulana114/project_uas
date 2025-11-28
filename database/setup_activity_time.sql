-- Setup tabel untuk menyimpan waktu aktivitas saat check-in
-- Jalankan script ini di Supabase SQL Editor

-- Tambahkan kolom duration_minutes ke tabel checkins
ALTER TABLE public.checkins 
ADD COLUMN IF NOT EXISTS duration_minutes INTEGER DEFAULT 0;

-- Buat index untuk mempercepat query
CREATE INDEX IF NOT EXISTS idx_checkins_duration ON public.checkins(duration_minutes);
CREATE INDEX IF NOT EXISTS idx_checkins_date_duration ON public.checkins(checkin_date, duration_minutes);

-- Update RPC check_in untuk menerima parameter duration
CREATE OR REPLACE FUNCTION public.rpc_check_in(
  p_user_challenge_id uuid,
  p_is_success boolean,
  p_checkin_date date default current_date,
  p_duration_minutes integer default 0
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_uc public.user_challenges%ROWTYPE;
  v_user public.users%ROWTYPE;
  v_points_awarded int := 0;
  v_completed boolean := false;
  v_total_days int := 0;
  v_reward int := 0;
BEGIN
  -- Validate challenge exists and is active (fetch challenge row only)
  SELECT *
    INTO v_uc
    FROM public.user_challenges uc
   WHERE uc.id = p_user_challenge_id
     AND uc.status = 'active';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tidak ada challenge aktif untuk check-in' USING ERRCODE = 'P0001';
  END IF;

  -- Fetch user row separately to avoid record field mismatch
  SELECT * INTO v_user FROM public.users u WHERE u.id = v_uc.user_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User tidak ditemukan untuk challenge ini' USING ERRCODE = 'P0001';
  END IF;

  -- Prevent double check-in per day
  BEGIN
    INSERT INTO public.checkins (user_challenge_id, checkin_date, is_success, duration_minutes)
    VALUES (p_user_challenge_id, p_checkin_date, p_is_success, p_duration_minutes);
  EXCEPTION WHEN unique_violation THEN
    RAISE EXCEPTION 'Anda sudah check-in hari ini' USING ERRCODE = 'P0001';
  END;

  -- Update challenge progress
  -- Calculate total days based on start/end
  v_total_days := GREATEST(1, (v_uc.end_date - v_uc.start_date + 1));

  UPDATE public.user_challenges
     SET current_day = v_uc.current_day + 1,
         success_days = v_uc.success_days + CASE WHEN p_is_success THEN 1 ELSE 0 END,
         status = CASE WHEN (v_uc.current_day + 1) >= v_total_days THEN 'completed' ELSE v_uc.status END,
         completed_at = CASE WHEN (v_uc.current_day + 1) >= v_total_days THEN NOW() ELSE v_uc.completed_at END
   WHERE id = p_user_challenge_id
   RETURNING * INTO v_uc;

  -- Update streaks (use v_user fields)
  UPDATE public.users
     SET current_streak = CASE WHEN p_is_success THEN COALESCE(v_user.current_streak, 0) + 1 ELSE 0 END,
         longest_streak = GREATEST(
            CASE WHEN p_is_success THEN COALESCE(v_user.current_streak, 0) + 1 ELSE 0 END,
            COALESCE(v_user.longest_streak, 0)
         )
   WHERE id = v_user.id
   RETURNING * INTO v_user;

  -- Check completion and award points from master challenge
  IF v_uc.status = 'completed' THEN
    v_completed := true;
    SELECT COALESCE(c.points_reward, 0) INTO v_reward
    FROM public.challenges c WHERE c.id = v_uc.challenge_id;
    v_points_awarded := COALESCE(v_reward, 0);
    UPDATE public.user_challenges
       SET points_earned = COALESCE(v_uc.points_earned, 0) + v_points_awarded
     WHERE id = p_user_challenge_id;
    UPDATE public.users
       SET total_points = COALESCE(v_user.total_points, 0) + v_points_awarded
     WHERE id = v_uc.user_id
     RETURNING * INTO v_user;
  END IF;

  -- Return composite json
  RETURN jsonb_build_object(
    'user_challenge', to_jsonb(v_uc),
    'is_success', p_is_success,
    'already_checked_in_today', false,
    'challenge_completed', v_completed,
    'points_awarded', v_points_awarded,
    'current_streak', v_user.current_streak,
    'longest_streak', v_user.longest_streak,
    'total_points', v_user.total_points,
    'duration_minutes', p_duration_minutes,
    -- convenience fields for client parsing
    'status', v_uc.status,
    'current_day', v_uc.current_day,
    'success_days', v_uc.success_days
  );
END;
$$;

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';

