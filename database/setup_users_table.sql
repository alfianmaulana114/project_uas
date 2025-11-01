-- ============================================================
-- SQL Script untuk Setup Tabel Users di Supabase
-- ============================================================
-- Script ini membuat tabel users untuk menyimpan profil user
-- Password disimpan di auth.users (managed by Supabase Auth)
-- ============================================================

-- Buat tabel users di schema public
CREATE TABLE IF NOT EXISTS public.users (
  -- ID dari auth.users (UUID)
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Email user (diambil dari auth.users saat signup)
  email TEXT NOT NULL,
  
  -- Nama lengkap user (opsional)
  full_name TEXT,
  
  -- Username user (opsional, unique)
  username TEXT UNIQUE,
  
  -- URL avatar user (opsional)
  avatar_url TEXT,
  
  -- Total points yang dimiliki user
  total_points INTEGER NOT NULL DEFAULT 0,
  
  -- Current streak (hari berturut-turut)
  current_streak INTEGER NOT NULL DEFAULT 0,
  
  -- Longest streak (streak terpanjang yang pernah dicapai)
  longest_streak INTEGER NOT NULL DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Buat index untuk mempercepat query
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON public.users(username);

-- ============================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================
-- Enable RLS untuk tabel users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies jika ada (untuk idempotency)
DROP POLICY IF EXISTS "Users can view all profiles" ON public.users;
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.users;

-- Policy: User bisa membaca semua profil user (public read)
CREATE POLICY "Users can view all profiles"
ON public.users
FOR SELECT
USING (true);

-- Policy: User bisa membaca profil sendiri
CREATE POLICY "Users can view own profile"
ON public.users
FOR SELECT
USING (auth.uid() = id);

-- Policy: User bisa insert profil sendiri saat signup
-- Menggunakan TO authenticated, anon untuk memastikan role bisa akses
CREATE POLICY "Users can insert own profile"
ON public.users
FOR INSERT
TO authenticated, anon
WITH CHECK (auth.uid() = id);

-- Policy: User bisa update profil sendiri
CREATE POLICY "Users can update own profile"
ON public.users
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Policy: User bisa delete profil sendiri (opsional)
CREATE POLICY "Users can delete own profile"
ON public.users
FOR DELETE
USING (auth.uid() = id);

-- ============================================================
-- FUNCTION: Auto update updated_at timestamp
-- ============================================================
-- Function untuk otomatis update updated_at saat data diubah
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger jika sudah ada (untuk idempotency)
DROP TRIGGER IF EXISTS set_updated_at ON public.users;

-- Trigger untuk auto update updated_at
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================
-- FUNCTION: Auto create user profile saat signup
-- ============================================================
-- Function untuk otomatis membuat profil user di tabel users
-- saat user baru signup di auth.users
-- Menggunakan SECURITY DEFINER untuk bypass RLS
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email)
  VALUES (NEW.id, COALESCE(NEW.email, ''))
  ON CONFLICT (id) DO UPDATE SET
    email = COALESCE(EXCLUDED.email, public.users.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- Drop trigger jika sudah ada (untuk idempotency)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Trigger untuk auto create user profile
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================
-- Setelah menjalankan script ini, verifikasi dengan query berikut:
-- SELECT * FROM public.users;
-- SELECT * FROM pg_policies WHERE tablename = 'users';

