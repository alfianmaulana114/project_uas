-- ============================================================
-- Script untuk Fix RLS Policy untuk Tabel Users
-- ============================================================
-- Error: new row violates row-level security policy (code: 42501)
-- Script ini memperbaiki RLS policies agar user bisa insert profil sendiri
-- ============================================================

-- Hapus semua policies yang ada terlebih dahulu
DROP POLICY IF EXISTS "Users can view all profiles" ON public.users;
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.users;

-- ============================================================
-- RLS POLICIES BARU (Diperbaiki)
-- ============================================================

-- Policy 1: User bisa INSERT profil sendiri saat signup
-- Menggunakan auth.uid() untuk memastikan user hanya bisa insert profil sendiri
CREATE POLICY "Users can insert own profile"
ON public.users
FOR INSERT
TO authenticated, anon
WITH CHECK (auth.uid() = id);

-- Policy 2: User bisa membaca semua profil (public read untuk profile listing)
CREATE POLICY "Public profiles are viewable by everyone"
ON public.users
FOR SELECT
TO authenticated, anon
USING (true);

-- Policy 3: User bisa membaca profil sendiri
CREATE POLICY "Users can view own profile"
ON public.users
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Policy 4: User bisa update profil sendiri
CREATE POLICY "Users can update own profile"
ON public.users
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Policy 5: User bisa delete profil sendiri (opsional)
CREATE POLICY "Users can delete own profile"
ON public.users
FOR DELETE
TO authenticated
USING (auth.uid() = id);

-- ============================================================
-- ALTERNATIVE: Jika masih error, gunakan function dengan SECURITY DEFINER
-- ============================================================
-- Function untuk insert user profile dengan bypass RLS
CREATE OR REPLACE FUNCTION public.insert_user_profile(
  user_id UUID,
  user_email TEXT,
  user_full_name TEXT DEFAULT NULL,
  user_username TEXT DEFAULT NULL
)
RETURNS public.users
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  new_user public.users;
BEGIN
  INSERT INTO public.users (id, email, full_name, username)
  VALUES (user_id, user_email, user_full_name, user_username)
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, public.users.full_name),
    username = COALESCE(EXCLUDED.username, public.users.username)
  RETURNING * INTO new_user;
  
  RETURN new_user;
END;
$$;

-- Grant execute permission untuk function
GRANT EXECUTE ON FUNCTION public.insert_user_profile(UUID, TEXT, TEXT, TEXT) TO authenticated, anon;

-- ============================================================
-- VERIFIKASI POLICIES
-- ============================================================
-- Query untuk melihat semua policies yang aktif
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users'
ORDER BY policyname;

-- ============================================================
-- TEST QUERY
-- ============================================================
-- Setelah menjalankan script, test dengan query ini (harus sebagai user yang sudah login):
-- SELECT * FROM public.users WHERE id = auth.uid();

