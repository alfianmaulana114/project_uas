-- Setup daily check-in RPC and supporting table
-- This script creates a "checkins" table and a Postgres function rpc_check_in
-- Business rules implemented:
-- 1) Prevent double check-in per day
-- 2) Require an active user_challenge
-- 3) Update user_challenges: current_day++, success_days++ when success
-- 4) Update users streaks: success => current_streak+1; failed => current_streak=0; update longest_streak
-- 5) Complete challenge when reach total_days and award challenge points
-- 6) Return a JSON object with updated challenge snapshot and user stats

begin;

-- Supporting table: checkins
create table if not exists public.checkins (
  id uuid primary key default gen_random_uuid(),
  user_challenge_id uuid not null references public.user_challenges(id) on delete cascade,
  checkin_date date not null default current_date,
  is_success boolean not null,
  created_at timestamp with time zone not null default now(),
  unique (user_challenge_id, checkin_date)
);

-- Ensure required columns exist on users
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'users' and column_name = 'total_points'
  ) then
    alter table public.users add column total_points integer not null default 0;
  end if;
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'users' and column_name = 'current_streak'
  ) then
    alter table public.users add column current_streak integer not null default 0;
  end if;
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'users' and column_name = 'longest_streak'
  ) then
    alter table public.users add column longest_streak integer not null default 0;
  end if;
end $$;

-- Check-in RPC
create or replace function public.rpc_check_in(
  p_user_challenge_id uuid,
  p_is_success boolean,
  p_checkin_date date default current_date
)
returns jsonb
language plpgsql
as $$
declare
  v_uc public.user_challenges%ROWTYPE;
  v_user public.users%ROWTYPE;
  v_points_awarded int := 0;
  v_completed boolean := false;
  v_total_days int := 0;
  v_reward int := 0;
begin
  -- Validate challenge exists and is active (fetch challenge row only)
  select *
    into v_uc
    from public.user_challenges uc
   where uc.id = p_user_challenge_id
     and uc.status = 'active';

  if not found then
    raise exception 'Tidak ada challenge aktif untuk check-in' using errcode = 'P0001';
  end if;

  -- Fetch user row separately to avoid record field mismatch
  select * into v_user from public.users u where u.id = v_uc.user_id;
  if not found then
    raise exception 'User tidak ditemukan untuk challenge ini' using errcode = 'P0001';
  end if;

  -- Prevent double check-in per day
  begin
    insert into public.checkins (user_challenge_id, checkin_date, is_success)
    values (p_user_challenge_id, p_checkin_date, p_is_success);
  exception when unique_violation then
    raise exception 'Anda sudah check-in hari ini' using errcode = 'P0001';
  end;

  -- Update challenge progress
  -- Calculate total days based on start/end
  v_total_days := greatest(1, (v_uc.end_date - v_uc.start_date + 1));

  update public.user_challenges
     set current_day = v_uc.current_day + 1,
         success_days = v_uc.success_days + case when p_is_success then 1 else 0 end,
         status = case when (v_uc.current_day + 1) >= v_total_days then 'completed' else v_uc.status end,
         completed_at = case when (v_uc.current_day + 1) >= v_total_days then now() else v_uc.completed_at end
   where id = p_user_challenge_id
   returning * into v_uc;

  -- Update streaks (use v_user fields)
  update public.users
     set current_streak = case when p_is_success then coalesce(v_user.current_streak, 0) + 1 else 0 end,
         longest_streak = greatest(
            case when p_is_success then coalesce(v_user.current_streak, 0) + 1 else 0 end,
            coalesce(v_user.longest_streak, 0)
         )
   where id = v_user.id
   returning * into v_user;

  -- Check completion and award points from master challenge
  if v_uc.status = 'completed' then
    v_completed := true;
    select coalesce(c.points_reward, 0) into v_reward
    from public.challenges c where c.id = v_uc.challenge_id;
    v_points_awarded := coalesce(v_reward, 0);
    update public.user_challenges
       set points_earned = coalesce(v_uc.points_earned, 0) + v_points_awarded
     where id = p_user_challenge_id;
    update public.users
       set total_points = coalesce(v_user.total_points, 0) + v_points_awarded
     where id = v_uc.user_id
     returning * into v_user;
  end if;

  -- Return composite json
  return jsonb_build_object(
    'user_challenge', to_jsonb(v_uc),
    'is_success', p_is_success,
    'already_checked_in_today', false,
    'challenge_completed', v_completed,
    'points_awarded', v_points_awarded,
    'current_streak', v_user.current_streak,
    'longest_streak', v_user.longest_streak,
    'total_points', v_user.total_points,
    -- convenience fields for client parsing
    'status', v_uc.status,
    'current_day', v_uc.current_day,
    'success_days', v_uc.success_days
  );
end;
$$;

commit;