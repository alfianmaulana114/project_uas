-- ============================================================
-- Script untuk Fix API Exposure dan Permissions
-- ============================================================
-- Script ini memastikan tabel users bisa diakses via PostgREST API
-- Jalankan script ini jika mendapat error 404 pada /rest/v1/users
-- ============================================================

-- Pastikan tabel users ada di schema public
-- (Jika error, berarti tabel belum dibuat - jalankan setup_users_table.sql dulu)
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'users'
);

-- ============================================================
-- GRANT PERMISSIONS untuk PostgREST API
-- ============================================================
-- PostgREST menggunakan role 'anon' dan 'authenticated' untuk akses API
-- Pastikan role ini punya permission untuk akses tabel users

-- Grant USAGE pada schema public (harus ada)
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Grant SELECT, INSERT, UPDATE, DELETE pada tabel users
GRANT SELECT, INSERT, UPDATE, DELETE ON public.users TO anon, authenticated;

-- Grant USAGE dan SELECT pada sequence (jika ada auto-increment)
-- (Tidak diperlukan untuk users karena menggunakan UUID, tapi tidak salah untuk ditambahkan)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Grant permission pada kolom-kolom tabel
GRANT SELECT, INSERT, UPDATE ON public.users TO anon, authenticated;

-- ============================================================
-- PASTIKAN SCHEMA PUBLIC TER-EXPOSE
-- ============================================================
-- Script ini akan memastikan schema public bisa diakses via API
-- (Biasanya sudah default, tapi untuk memastikan)

-- Set default privileges untuk future tables di schema public
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO anon, authenticated;

-- Set default privileges untuk sequences
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT USAGE, SELECT ON SEQUENCES TO anon, authenticated;

-- ============================================================
-- VERIFIKASI PERMISSIONS
-- ============================================================
-- Query untuk cek permissions yang sudah diberikan
SELECT 
  grantee,
  privilege_type,
  table_name
FROM information_schema.role_table_grants
WHERE table_schema = 'public' 
AND table_name = 'users'
ORDER BY grantee, privilege_type;

-- ============================================================
-- PASTIKAN RLS ENABLED (jika diperlukan)
-- ============================================================
-- RLS harus enabled untuk security, tapi pastikan policies sudah benar
-- (Sudah di-handle di setup_users_table.sql)

-- Verifikasi RLS status
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public' 
AND tablename = 'users';

-- ============================================================
-- NOTIFY PGREST untuk reload schema
-- ============================================================
-- Ini akan memaksa PostgREST untuk reload schema dan detect tabel baru
NOTIFY pgrst, 'reload schema';

-- ============================================================
-- CATATAN PENTING
-- ============================================================
-- Setelah menjalankan script ini:
-- 1. Pastikan di Supabase Dashboard → Settings → API → Exposed schemas
--    memuat "public" dalam daftar
-- 2. Refresh Schema Cache jika diperlukan
-- 3. Tunggu 1-2 menit untuk PostgREST reload schema
-- 4. Coba lagi request API

