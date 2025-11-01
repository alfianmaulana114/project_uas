# 🔒 Troubleshooting RLS Policy Error (42501)

## ⚠️ Error: `new row violates row-level security policy for table "users"`

Error code **42501** berarti RLS (Row Level Security) policy memblokir operasi INSERT ke tabel `users`.

## 🔍 Penyebab

RLS policy tidak mengizinkan user untuk insert profil sendiri saat signup. Ini terjadi karena:
1. Policy INSERT tidak tepat atau tidak ada
2. Role `anon` atau `authenticated` tidak memiliki akses
3. Condition `auth.uid() = id` tidak terpenuhi saat insert

## ✅ Solusi

### Solusi 1: Update RLS Policy (RECOMMENDED)

1. **Buka Supabase Dashboard** → **SQL Editor**
2. **Copy dan jalankan script** `database/fix_rls_policy.sql`
3. Script ini akan:
   - Menghapus policies lama yang bermasalah
   - Membuat policies baru yang benar
   - Menambahkan function untuk insert dengan SECURITY DEFINER

### Solusi 2: Gunakan Function dengan SECURITY DEFINER

Script `fix_rls_policy.sql` sudah termasuk function `insert_user_profile()` yang menggunakan `SECURITY DEFINER` untuk bypass RLS.

Jika masih error, kita bisa ubah kode untuk menggunakan function ini. (Tapi sebaiknya fix policy dulu)

### Solusi 3: Update Setup Script

1. **Hapus dan buat ulang policies** dengan script yang sudah diperbaiki:
   - Jalankan `database/fix_rls_policy.sql` untuk fix policies
   - Atau jalankan `database/setup_users_table.sql` lagi (sudah diperbaiki)

## 📋 Langkah Fix (Urut!)

### Step 1: Jalankan Fix RLS Policy Script
```sql
-- Copy semua isi dari database/fix_rls_policy.sql
-- Paste ke SQL Editor dan Run
```

### Step 2: Verifikasi Policies
Jalankan query ini untuk cek policies:
```sql
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users';
```

Pastikan ada policy dengan:
- `cmd = 'INSERT'`
- `roles` berisi `{authenticated, anon}`
- `with_check` berisi `(auth.uid() = id)`

### Step 3: Test Kembali
1. Restart aplikasi
2. Coba signup lagi
3. Error seharusnya sudah hilang

## 🔧 Alternative: Disable RLS (TIDAK RECOMMENDED untuk Production)

Jika masih error dan untuk development saja, bisa nonaktifkan RLS sementara:

```sql
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
```

**WARNING**: Ini menghilangkan keamanan! Hanya untuk development/testing.

## 📝 Penjelasan Policy yang Benar

Policy INSERT yang benar harus:
```sql
CREATE POLICY "Users can insert own profile"
ON public.users
FOR INSERT
TO authenticated, anon  -- Penting: harus include role anon dan authenticated
WITH CHECK (auth.uid() = id);  -- User hanya bisa insert profil sendiri
```

## ✅ Checklist

Setelah fix, pastikan:
- [ ] Policy INSERT ada dan aktif
- [ ] Policy mencakup role `anon` dan `authenticated`
- [ ] `WITH CHECK` condition benar: `auth.uid() = id`
- [ ] Function `handle_new_user()` menggunakan `SECURITY DEFINER`
- [ ] Permissions sudah diberikan ke role `anon` dan `authenticated`
- [ ] Test signup berhasil tanpa error RLS

## 🆘 Jika Masih Error

1. **Cek Auth Status**: Pastikan user sudah ter-authenticate saat insert
   - User baru dibuat di `auth.users` saat signup
   - Tapi mungkin session belum tersedia saat insert ke `public.users`

2. **Cek Trigger**: Pastikan trigger `on_auth_user_created` aktif
   - Trigger ini menggunakan `SECURITY DEFINER` dan bisa bypass RLS

3. **Gunakan Function**: Jika policy masih bermasalah, ubah kode untuk menggunakan function `insert_user_profile()`

