# 🐛 Troubleshooting Error 400 (Bad Request) pada Signup

## ⚠️ Error: `POST /auth/v1/signup 400 (Bad Request)`

Error 400 biasanya terjadi karena request tidak valid. Berikut beberapa penyebab dan solusinya:

## 🔍 Penyebab Umum

### 1. Email sudah terdaftar
- **Gejala**: Error 400 dengan pesan "User already registered"
- **Solusi**: Gunakan email lain atau coba login jika sudah punya akun

### 2. Format email tidak valid
- **Gejala**: Email tidak memenuhi format standar
- **Solusi**: Pastikan email menggunakan format: `nama@domain.com`
- **Contoh valid**: `user@example.com`, `test123@gmail.com`
- **Contoh invalid**: `userexample.com`, `user@`, `@example.com`

### 3. Password tidak memenuhi requirement
- **Gejala**: Password terlalu pendek atau tidak valid
- **Solusi**: 
  - Password minimal **6 karakter**
  - Gunakan kombinasi huruf dan angka untuk keamanan lebih baik

### 4. Email Confirmation diaktifkan di Supabase
- **Gejala**: User dibuat tapi session null, harus konfirmasi email dulu
- **Solusi**: 
  1. Cek email inbox (dan spam) untuk email konfirmasi
  2. Klik link konfirmasi di email
  3. Atau nonaktifkan email confirmation di Supabase Dashboard

### 5. Sign up dinonaktifkan di Supabase
- **Gejala**: Error dengan pesan "signup disabled"
- **Solusi**: Aktifkan sign up di Supabase Dashboard → Authentication → Settings

## ✅ Checklist untuk Fix Error 400

### Step 1: Verifikasi Data Input
- [ ] Email menggunakan format yang benar (`user@domain.com`)
- [ ] Password minimal 6 karakter
- [ ] Email belum pernah terdaftar sebelumnya
- [ ] Semua field required sudah diisi

### Step 2: Cek Konfigurasi Supabase Auth

1. **Buka Supabase Dashboard** → **Authentication** → **Settings**

2. **Enable Email Auth**:
   - Pastikan "Enable Email Signup" aktif (ON)
   - Pastikan "Enable Email Confirmations" sesuai kebutuhan:
     - **ON** = User harus konfirmasi email dulu
     - **OFF** = User langsung bisa login setelah signup

3. **Cek Email Templates**:
   - Buka **Authentication** → **Email Templates**
   - Pastikan template "Confirm signup" ada dan aktif

### Step 3: Test dengan Email Baru

Coba signup dengan:
- Email yang benar-benar baru (belum pernah digunakan)
- Format email yang valid
- Password minimal 6 karakter

### Step 4: Cek Error Message Detail

Jika masih error, cek:
1. **Browser Console** - Lihat error message lengkap
2. **Supabase Dashboard** → **Logs** → **Auth Logs** - Lihat detail error dari server
3. **Network Tab** - Lihat response body dari request `/auth/v1/signup`

## 🔧 Fix via Supabase Dashboard

### Nonaktifkan Email Confirmation (Untuk Development)

1. Buka **Authentication** → **Settings**
2. Scroll ke **"Email Auth"**
3. Nonaktifkan **"Enable Email Confirmations"**
4. Klik **Save**
5. Coba signup lagi

### Aktifkan Sign Up (Jika dinonaktifkan)

1. Buka **Authentication** → **Settings**
2. Scroll ke **"Email Auth"**
3. Pastikan **"Enable Email Signup"** aktif (ON)
4. Klik **Save**

## 📝 Code yang Sudah Diperbaiki

Error handling sudah diperbaiki untuk:
- ✅ Menangkap error 400 dengan lebih detail
- ✅ Memberikan pesan error yang lebih informatif
- ✅ Validasi email format sebelum request ke server
- ✅ Validasi password minimal 6 karakter

## 🧪 Test Cases

Coba test dengan skenario berikut:

1. **Valid signup**:
   - Email: `test@example.com`
   - Password: `password123`
   - Expected: ✅ Berhasil

2. **Email sudah terdaftar**:
   - Email: `test@example.com` (sudah digunakan)
   - Password: `password123`
   - Expected: ❌ Error "Email sudah terdaftar"

3. **Email tidak valid**:
   - Email: `invalid-email`
   - Password: `password123`
   - Expected: ❌ Error "Format email tidak valid"

4. **Password terlalu pendek**:
   - Email: `test@example.com`
   - Password: `12345` (5 karakter)
   - Expected: ❌ Error "Password minimal 6 karakter"

## 💡 Tips

1. **Untuk Development**: Nonaktifkan email confirmation agar lebih cepat test
2. **Untuk Production**: Aktifkan email confirmation untuk keamanan
3. **Password**: Gunakan minimal 8 karakter dengan kombinasi huruf, angka, dan simbol
4. **Error Logging**: Selalu cek console log untuk detail error

## 📞 Jika Masih Error

Jika error 400 masih muncul setelah semua langkah di atas:

1. Cek **Auth Logs** di Supabase Dashboard untuk detail error
2. Copy error message lengkap dari browser console
3. Cek apakah ada error lain di bagian network request
4. Pastikan API key dan URL Supabase sudah benar di `main.dart`

