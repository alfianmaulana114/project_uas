# 🚫 Setup App Blocking - Detox Social Media

## 📋 Overview

Fitur App Blocking memungkinkan aplikasi untuk **benar-benar memblokir** aplikasi yang ditandai sebagai diblokir. Ketika pengguna mencoba membuka aplikasi yang diblokir, aplikasi akan otomatis menutup aplikasi tersebut dan menampilkan layar blocking.

## ⚙️ Cara Setup

### 1. Install Aplikasi
Pastikan aplikasi sudah diinstall di perangkat Android Anda.

### 2. Aktifkan Accessibility Service

**Langkah-langkah:**

1. Buka aplikasi **Detox Social Media**
2. Ketika pertama kali menggunakan fitur blocking, aplikasi akan meminta Anda untuk mengaktifkan **Accessibility Service**
3. Klik tombol **"Aktifkan"** pada dialog yang muncul
4. Aplikasi akan membuka **Pengaturan Android** → **Accessibility**
5. Cari aplikasi **"Detox Social Media"** atau **"AppBlockingService"** dalam daftar
6. **Aktifkan** toggle untuk aplikasi tersebut
7. Kembali ke aplikasi

**Atau secara manual:**
- Buka **Settings** → **Accessibility**
- Cari **"Detox Social Media"** atau **"AppBlockingService"**
- Aktifkan toggle

### 3. Berikan Izin Overlay (Opsional)

Untuk layar blocking yang lebih baik, berikan izin overlay:
- Buka **Settings** → **Apps** → **Special app access** → **Display over other apps**
- Cari **"Detox Social Media"**
- Aktifkan toggle

### 4. Gunakan Fitur Blocking

1. Buka halaman **Challenge** atau halaman yang memiliki fitur blocking
2. Pilih aplikasi yang ingin diblokir
3. Klik tombol **"Blokir"**
4. Aplikasi akan ditambahkan ke daftar block
5. Ketika aplikasi yang diblokir dibuka, aplikasi akan otomatis ditutup dan menampilkan layar blocking

## 🔧 Cara Kerja

1. **Accessibility Service** memantau aplikasi yang dibuka
2. Ketika aplikasi yang diblokir terdeteksi, service akan:
   - Menutup aplikasi tersebut
   - Menampilkan **BlockingOverlayActivity** dengan pesan blocking
3. Pengguna tidak bisa membuka aplikasi yang diblokir sampai di-unblock

## ⚠️ Catatan Penting

- **Accessibility Service wajib diaktifkan** untuk fitur blocking berfungsi
- Aplikasi sistem (system apps) tidak bisa diblokir
- Beberapa aplikasi mungkin memerlukan izin tambahan
- Fitur ini hanya tersedia untuk **Android** (iOS tidak mendukung)

## 🐛 Troubleshooting

### Accessibility Service tidak terdeteksi
1. Pastikan service sudah diaktifkan di Settings → Accessibility
2. Restart aplikasi
3. Cek kembali status di aplikasi

### Aplikasi masih bisa dibuka meskipun sudah diblokir
1. Pastikan Accessibility Service sudah aktif
2. Pastikan blocking sudah di-enable di aplikasi
3. Restart aplikasi
4. Cek apakah package name aplikasi sudah benar

### Layar blocking tidak muncul
1. Berikan izin overlay (Display over other apps)
2. Restart aplikasi
3. Cek log untuk error

## 📱 Dukungan Platform

- ✅ **Android**: Fully Supported
- ❌ **iOS**: Not Supported (iOS tidak mengizinkan aplikasi pihak ketiga untuk memblokir aplikasi lain)

## 🔒 Keamanan

- Accessibility Service hanya digunakan untuk memblokir aplikasi yang ditandai oleh pengguna
- Tidak ada data yang dikirim ke server
- Semua data blocking disimpan lokal di perangkat

