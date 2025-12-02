# Setup Storage Policy untuk Upload Avatar

## 📋 Overview

File ini menjelaskan cara setup Storage Policy di Supabase agar fitur upload gambar profil bisa berfungsi dengan baik.

## 🚀 Langkah-langkah Setup

### Langkah 1: Pastikan Bucket 'avatars' Sudah Dibuat

1. Buka [Supabase Dashboard](https://supabase.com/dashboard)
2. Pilih project Anda
3. Buka menu **Storage** di sidebar kiri
4. Pastikan bucket dengan nama `avatars` sudah ada
5. Jika belum ada, klik **New bucket** dan buat bucket dengan nama `avatars`
6. **PENTING**: Set bucket sebagai **PUBLIC** (agar URL bisa diakses)

### Langkah 2: Setup Storage Policy

1. Buka menu **SQL Editor** di Supabase Dashboard
2. Copy semua isi dari file `setup_storage_policy.sql`
3. Paste ke SQL Editor
4. Klik tombol **Run** atau tekan `Ctrl+Enter` (Windows) / `Cmd+Enter` (Mac)

### Langkah 3: Verifikasi Policy

1. Buka menu **Storage** → **Policies**
2. Pilih bucket `avatars`
3. Pastikan ada 4 policies:
   - ✅ "Users can upload their own avatars" (INSERT)
   - ✅ "Users can update their own avatars" (UPDATE)
   - ✅ "Public can read avatars" (SELECT)
   - ✅ "Users can delete their own avatars" (DELETE)

## 🔒 Penjelasan Policy

### Policy 1: Upload (INSERT)
- **Siapa**: User yang sudah login (authenticated)
- **Apa**: Bisa upload file ke folder mereka sendiri
- **Dimana**: Folder dengan nama = user ID mereka

### Policy 2: Update (UPDATE)
- **Siapa**: User yang sudah login
- **Apa**: Bisa update file mereka sendiri
- **Dimana**: Hanya file di folder mereka sendiri

### Policy 3: Read (SELECT)
- **Siapa**: Semua orang (public)
- **Apa**: Bisa membaca/melihat semua avatar
- **Dimana**: Semua file di bucket avatars

### Policy 4: Delete (DELETE)
- **Siapa**: User yang sudah login
- **Apa**: Bisa menghapus file mereka sendiri
- **Dimana**: Hanya file di folder mereka sendiri

## ⚠️ Troubleshooting

### Error: "Tidak memiliki izin untuk upload gambar"

**Solusi:**
1. Pastikan bucket `avatars` sudah dibuat dan set sebagai PUBLIC
2. Pastikan Storage Policy sudah dijalankan (lihat Langkah 2)
3. Pastikan user sudah login sebelum upload
4. Refresh aplikasi setelah setup policy

### Error: "Bucket not found"

**Solusi:**
1. Buat bucket `avatars` di Supabase Dashboard → Storage
2. Set bucket sebagai PUBLIC
3. Refresh aplikasi

### Error: "Policy tidak bekerja"

**Solusi:**
1. Cek apakah policy sudah dibuat di Storage → Policies
2. Pastikan policy menggunakan nama bucket yang benar: `avatars`
3. Pastikan user sudah login (authenticated)
4. Coba hapus dan buat ulang policy jika perlu

## 📝 Catatan Penting

- **Bucket harus PUBLIC** agar URL avatar bisa diakses
- **Policy harus dijalankan** setelah membuat bucket
- **User harus login** sebelum bisa upload
- **File disimpan di folder** dengan nama = user ID

## ✅ Checklist Setup

- [ ] Bucket `avatars` sudah dibuat
- [ ] Bucket `avatars` set sebagai PUBLIC
- [ ] Storage Policy sudah dijalankan (4 policies)
- [ ] Policy sudah diverifikasi di Storage → Policies
- [ ] Aplikasi sudah di-restart setelah setup

Setelah semua checklist selesai, fitur upload avatar seharusnya sudah berfungsi! 🎉

