# 🔧 Complete Database Setup Guide

## ⚠️ Masalah: Error 404 pada `/rest/v1/users`

Error 404 biasanya terjadi karena:
1. Tabel `users` belum dibuat
2. Tabel ada tapi tidak ter-expose ke PostgREST API
3. Permissions belum diberikan untuk role `anon` dan `authenticated`

## 📋 Langkah-langkah Setup (URUT!)

### Step 1: Buat Tabel Users
1. Buka **Supabase Dashboard** → **SQL Editor**
2. Copy semua isi dari `database/setup_users_table.sql`
3. Paste dan klik **Run**
4. Pastikan tidak ada error

### Step 2: Fix API Exposure & Permissions
1. Masih di **SQL Editor**
2. Copy semua isi dari `database/fix_api_exposure.sql`
3. Paste dan klik **Run**
4. Pastikan tidak ada error

### Step 3: Verifikasi Settings di Dashboard

#### 3.1. Check Exposed Schemas
1. Buka **Settings** → **API** (Data API)
2. Pastikan di bagian **"Exposed schemas"** ada **"public"**
3. Jika tidak ada, tambahkan "public"

#### 3.2. Check Table di Table Editor
1. Buka **Table Editor** di sidebar
2. Pastikan tabel **"users"** muncul di list
3. Klik tabel **"users"** untuk melihat strukturnya

#### 3.3. Refresh Schema Cache (Jika diperlukan)
1. Buka **SQL Editor**
2. Jalankan query ini:
```sql
NOTIFY pgrst, 'reload schema';
```
3. Klik **Run**

### Step 4: Verifikasi Permissions

Jalankan query ini di SQL Editor untuk cek permissions:

```sql
SELECT 
  grantee,
  privilege_type,
  table_name
FROM information_schema.role_table_grants
WHERE table_schema = 'public' 
AND table_name = 'users'
ORDER BY grantee, privilege_type;
```

Harus ada:
- `anon` dengan privileges: SELECT, INSERT, UPDATE, DELETE
- `authenticated` dengan privileges: SELECT, INSERT, UPDATE, DELETE

### Step 5: Test Query via SQL Editor

Coba query ini untuk test apakah tabel bisa diakses:

```sql
SELECT * FROM public.users LIMIT 1;
```

Jika berhasil, berarti tabel sudah benar.

## 🐛 Troubleshooting

### Error 404 masih muncul setelah setup
1. **Tunggu 1-2 menit** - PostgREST butuh waktu untuk reload schema
2. **Restart aplikasi** - Hot restart tidak cukup, full restart
3. **Check URL Supabase** - Pastikan URL di `main.dart` benar
4. **Check API Key** - Pastikan anon key di `main.dart` benar

### Error "relation users does not exist"
- Tabel belum dibuat, jalankan `setup_users_table.sql` lagi

### Error "permission denied" atau RLS violation
- Permissions belum diberikan, jalankan `fix_api_exposure.sql` lagi
- Atau RLS policies terlalu ketat, cek policies di SQL Editor

### Error 422 pada signup
- Biasanya karena email sudah terdaftar atau password tidak valid
- Bukan masalah tabel, ini masalah validasi

## ✅ Checklist Final

Sebelum test aplikasi, pastikan:
- [ ] Tabel `users` sudah dibuat (terlihat di Table Editor)
- [ ] Permissions sudah diberikan (`fix_api_exposure.sql` sudah dijalankan)
- [ ] Schema "public" ter-expose di Settings → API
- [ ] RLS policies sudah dibuat (5 policies)
- [ ] Trigger `on_auth_user_created` sudah dibuat
- [ ] Query `NOTIFY pgrst, 'reload schema';` sudah dijalankan
- [ ] Tunggu 1-2 menit setelah semua setup

## 📞 Jika Masih Error

1. Cek **Logs** di Supabase Dashboard → **Logs** → **API Logs**
2. Cek error message di console browser/app
3. Pastikan semua script sudah dijalankan dengan benar
4. Pastikan urutan setup sudah benar (setup_users_table.sql dulu, lalu fix_api_exposure.sql)

