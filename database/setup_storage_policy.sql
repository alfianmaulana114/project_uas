-- ============================================================
-- SQL Script untuk Setup Storage Policy di Supabase
-- ============================================================
-- Script ini membuat Storage Policy untuk bucket 'avatars'
-- agar user bisa upload dan read gambar profil mereka
-- ============================================================

-- Pastikan bucket 'avatars' sudah dibuat dan set sebagai PUBLIC
-- Jika belum, buat di Supabase Dashboard → Storage → New Bucket

-- ============================================================
-- STORAGE POLICIES UNTUK BUCKET 'avatars'
-- ============================================================

-- Hapus policy lama jika sudah ada (untuk menghindari duplikat)
DROP POLICY IF EXISTS "Users can upload their own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Public can read avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatars" ON storage.objects;

-- Policy 1: Allow authenticated users to upload files to their own folder
CREATE POLICY "Users can upload their own avatars"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 2: Allow authenticated users to update their own avatars
CREATE POLICY "Users can update their own avatars"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 3: Allow everyone (including anonymous) to read avatars (PUBLIC)
CREATE POLICY "Public can read avatars"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Policy 4: Allow authenticated users to delete their own avatars
CREATE POLICY "Users can delete their own avatars"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================================
-- CATATAN PENTING:
-- ============================================================
-- 1. Pastikan bucket 'avatars' sudah dibuat di Supabase Dashboard
-- 2. Set bucket sebagai PUBLIC agar URL bisa diakses
-- 3. Jalankan script ini di Supabase SQL Editor
-- 4. Setelah menjalankan, refresh aplikasi dan coba upload lagi
-- ============================================================

