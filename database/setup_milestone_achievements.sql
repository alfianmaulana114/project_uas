-- Setup Milestone Achievements
-- Achievement untuk milestone seperti 7 hari streak, 30 hari challenge, dll

-- Pastikan tabel achievements sudah ada
-- Jika belum, buat dulu dengan struktur:
-- CREATE TABLE achievements (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   name TEXT NOT NULL,
--   description TEXT,
--   badge_icon TEXT,
--   requirement_type TEXT NOT NULL,
--   requirement_value INTEGER NOT NULL,
--   points_reward INTEGER NOT NULL DEFAULT 0,
--   created_at TIMESTAMP DEFAULT NOW()
-- );

-- Insert milestone achievements
-- Streak Milestones
  INSERT INTO achievements (name, description, badge_icon, requirement_type, requirement_value, points_reward)
  VALUES 
    ('Streak 7 Hari', 'Pertahankan streak selama 7 hari berturut-turut', '🔥', 'streak_days', 7, 50),
    ('Streak 14 Hari', 'Pertahankan streak selama 14 hari berturut-turut', '🔥🔥', 'streak_days', 14, 100),
    ('Streak 30 Hari', 'Pertahankan streak selama 30 hari berturut-turut', '🔥🔥🔥', 'streak_days', 30, 250),
    ('Streak 60 Hari', 'Pertahankan streak selama 60 hari berturut-turut', '🔥🔥🔥🔥', 'streak_days', 60, 500),
    ('Streak 100 Hari', 'Pertahankan streak selama 100 hari berturut-turut', '🔥🔥🔥🔥🔥', 'streak_days', 100, 1000)
  ON CONFLICT DO NOTHING;

  -- Challenge Completion Milestones
  INSERT INTO achievements (name, description, badge_icon, requirement_type, requirement_value, points_reward)
  VALUES 
    ('Challenge Pertama', 'Selesaikan challenge pertama', '🎯', 'complete_challenge', 1, 25),
    ('Challenge Master', 'Selesaikan 5 challenge', '🎯🎯', 'complete_challenge', 5, 100),
    ('Challenge Expert', 'Selesaikan 10 challenge', '🎯🎯🎯', 'complete_challenge', 10, 200),
    ('Challenge Legend', 'Selesaikan 30 challenge', '🎯🎯🎯🎯', 'complete_challenge', 30, 500),
    ('Challenge Champion', 'Selesaikan 50 challenge', '🎯🎯🎯🎯🎯', 'complete_challenge', 50, 1000)
  ON CONFLICT DO NOTHING;

  -- Check-in Milestones
  INSERT INTO achievements (name, description, badge_icon, requirement_type, requirement_value, points_reward)
  VALUES 
    ('Check-in Pertama', 'Lakukan check-in pertama', '✅', 'first_checkin', 1, 10),
    ('Check-in 10 Hari', 'Lakukan check-in selama 10 hari', '✅✅', 'check_in_days', 10, 50),
    ('Check-in 30 Hari', 'Lakukan check-in selama 30 hari', '✅✅✅', 'check_in_days', 30, 150),
    ('Check-in 60 Hari', 'Lakukan check-in selama 60 hari', '✅✅✅✅', 'check_in_days', 60, 300),
    ('Check-in 100 Hari', 'Lakukan check-in selama 100 hari', '✅✅✅✅✅', 'check_in_days', 100, 500)
  ON CONFLICT DO NOTHING;

-- Note: Jika ada conflict (achievement sudah ada), query akan diabaikan (ON CONFLICT DO NOTHING)
-- Untuk update achievement yang sudah ada, gunakan:
-- UPDATE achievements SET points_reward = 50 WHERE name = 'Streak 7 Hari';

