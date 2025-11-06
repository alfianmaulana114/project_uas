# Database Setup Guide - Supabase

## 📋 Overview

File-file di folder ini berisi SQL scripts untuk setup database di Supabase.

## 🚀 Cara Setup Tabel Users

### Langkah 1: Buka Supabase Dashboard
1. Login ke [Supabase Dashboard](https://supabase.com/dashboard)
2. Pilih project Anda
3. Buka menu **SQL Editor** di sidebar kiri

### Langkah 2: Jalankan SQL Script
1. Copy semua isi dari file `setup_users_table.sql`
2. Paste ke SQL Editor di Supabase
3. Klik tombol **Run** atau tekan `Ctrl+Enter` (Windows) / `Cmd+Enter` (Mac)

### Langkah 3: Refresh Schema Cache
1. Buka menu **Settings** → **API**
2. Scroll ke bawah, cari bagian **Schema Cache**
3. Klik tombol **Refresh Schema Cache**

### Langkah 4: Verifikasi
Setelah menjalankan script, verifikasi dengan:
1. Buka menu **Table Editor** di sidebar
2. Pastikan tabel `users` sudah muncul di list tabel
3. Klik tabel `users` untuk melihat strukturnya

## 📊 Struktur Tabel Users

Tabel `users` memiliki kolom berikut:
- `id` (UUID, Primary Key) - ID dari auth.users
- `email` (TEXT, NOT NULL) - Email user
- `full_name` (TEXT, nullable) - Nama lengkap
- `username` (TEXT, nullable, unique) - Username
- `avatar_url` (TEXT, nullable) - URL avatar
- `total_points` (INTEGER, default 0) - Total points
- `current_streak` (INTEGER, default 0) - Streak saat ini
- `longest_streak` (INTEGER, default 0) - Streak terpanjang
- `created_at` (TIMESTAMP) - Waktu dibuat
- `updated_at` (TIMESTAMP) - Waktu diupdate

## 🔒 Row Level Security (RLS)

RLS sudah diaktifkan dengan policies berikut:
- ✅ Semua user bisa membaca profil semua user (public read)
- ✅ User bisa membaca, update, dan delete profil sendiri
- ✅ User bisa insert profil sendiri saat signup

## ⚙️ Auto Functions

Script juga membuat:
1. **Auto Update Timestamp**: Otomatis update `updated_at` saat data diubah
2. **Auto Create Profile**: Otomatis membuat profil di tabel `users` saat user signup

## ⚠️ Troubleshooting

### Error: "Tabel users tidak ditemukan"
- Pastikan SQL script sudah dijalankan dengan benar
- Refresh Schema Cache di Supabase Dashboard (Settings → API)
- Cek di Table Editor apakah tabel sudah ada

### Error: "permission denied" atau "RLS policy violation"
- Pastikan RLS policies sudah dibuat dengan benar
- Cek apakah user sudah login (auth.uid() harus ada)
- Pastikan trigger `handle_new_user` sudah dibuat

### Error: "duplicate key" saat signup
- Pastikan trigger `handle_new_user` tidak membuat duplikasi
- Hapus trigger lama jika ada, lalu buat ulang

## 📝 Catatan Penting

1. **Password TIDAK disimpan di tabel users** - Password disimpan di `auth.users` (managed by Supabase Auth)
2. **ID di tabel users harus sama dengan ID di auth.users** - Ini dilakukan via foreign key constraint
3. **Trigger auto-create profile** - Saat user signup via Supabase Auth, profil akan otomatis dibuat di tabel users


## ➕ Fitur Tambahan: Check-In Harian

Untuk mengaktifkan fitur check-in harian dan RPC yang dipanggil dari aplikasi, jalankan script berikut:

1. Buka **Supabase Dashboard** → **SQL Editor**
2. Copy semua isi dari file `setup_checkin_rpc.sql`
3. Paste dan klik **Run**
4. Jalankan query `NOTIFY pgrst, 'reload schema';` untuk refresh schema

Script ini akan:
- Membuat tabel `checkins` dengan unique (user_challenge_id, checkin_date)
- Membuat fungsi `rpc_check_in` yang meng-update: progress challenge, streak user, dan poin
- Mengembalikan JSON berisi snapshot challenge dan statistik user

