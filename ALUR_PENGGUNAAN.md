# 📱 Alur Penggunaan Aplikasi Detox Social Media

Dokumentasi lengkap tentang cara menggunakan aplikasi dari awal hingga fitur blocking berfungsi.

---

## 🚀 1. Instalasi Aplikasi

### Langkah 1: Install APK
1. Transfer file `app-release.apk` ke device Android Anda
2. Buka file manager dan tap file APK
3. Jika muncul peringatan "Play Protect", tap **"Install anyway"** atau **"Tetap install"**
4. Tap **"Install"** dan tunggu proses instalasi selesai
5. Tap **"Open"** untuk membuka aplikasi

### Langkah 2: First Time Setup
1. Aplikasi akan meminta login/register
2. Isi data yang diperlukan (email, password, dll)
3. Setelah login, Anda akan masuk ke halaman Dashboard

---

## 🎯 2. Setup Fitur Blocking (PENTING!)

### Langkah 1: Aktifkan Accessibility Service

**Ini adalah langkah WAJIB agar blocking berfungsi!**

1. Buka aplikasi **Detox Social Media**
2. Pergi ke halaman **Challenge** (tab di bawah)
3. Pilih aplikasi yang ingin diblokir (misalnya Instagram, TikTok)
4. Tap tombol **"Blokir"**
5. Akan muncul dialog: **"Aktifkan Accessibility Service"**
6. Tap **"Aktifkan"**
7. Aplikasi akan membuka **Settings Android** → **Accessibility**
8. Di halaman Accessibility, cari **"Detox Social Media"** atau **"AppBlockingService"**
9. Tap pada item tersebut
10. **Aktifkan toggle** (geser ke kanan/ON)
11. Tap **"Allow"** atau **"Izinkan"** pada dialog konfirmasi
12. **Kembali ke aplikasi**

### Langkah 2: Aktifkan Blocking di Aplikasi

1. Setelah Accessibility Service aktif, kembali ke aplikasi
2. Pastikan toggle **"Detox Social Media"** sudah **ON** (hijau)
   - Jika belum, tap toggle untuk mengaktifkannya
3. Toggle **"Pintasan Detox Social Media"** bisa diaktifkan (opsional)

### Langkah 3: Blokir Aplikasi

1. Buka halaman **Challenge**
2. Di bagian **"Diblokir"**, Anda akan melihat daftar aplikasi yang bisa diblokir
3. Tap tombol **"Blokir"** pada aplikasi yang ingin diblokir
   - Contoh: Instagram, TikTok, Twitter/X, YouTube, dll
4. Aplikasi akan ditambahkan ke daftar block
5. Muncul notifikasi: **"[Nama App] diblokir."**

---

## ✅ 3. Verifikasi Blocking Berfungsi

### Cara Test:

1. **Tutup aplikasi Detox Social Media** (biarkan berjalan di background)
2. **Buka aplikasi yang sudah diblokir** (misalnya Instagram)
3. **Hasil yang diharapkan:**
   - Aplikasi akan **langsung tertutup** dalam hitungan detik
   - Muncul layar blocking merah dengan pesan: **"⚠️ Aplikasi Diblokir!"**
   - Muncul toast notification: **"⚠️ [Nama App] sedang diblokir!"**
   - Aplikasi tidak bisa dibuka sampai di-unblock

### Jika Masih Bisa Dibuka:

1. **Cek Accessibility Service:**
   - Settings → Accessibility → Detox Social Media
   - Pastikan toggle **ON** (hijau)

2. **Cek Toggle di Aplikasi:**
   - Pastikan toggle **"Detox Social Media"** **ON**

3. **Cek Daftar Block:**
   - Pastikan aplikasi sudah ada di daftar **"Diblokir"**

4. **Restart Aplikasi:**
   - Tutup aplikasi Detox Social Media
   - Buka kembali aplikasi

---

## 📋 4. Alur Penggunaan Lengkap

### A. Membuat Challenge

1. Buka tab **Challenge**
2. Pilih jenis challenge (misalnya: Social Media Challenge)
3. Set durasi challenge (misalnya: 7 hari)
4. Pilih aplikasi yang ingin diblokir
5. Tap **"Mulai Challenge"**
6. Challenge akan aktif dan aplikasi yang dipilih otomatis diblokir

### B. Check-in Harian

1. Setiap hari, buka aplikasi
2. Tap tombol **"Check-in"** di Dashboard
3. Isi mood/jurnal harian (opsional)
4. Dapatkan poin untuk setiap check-in
5. Streak akan bertambah jika check-in konsisten

### C. Melihat Progress

1. Buka tab **Analytics**
2. Lihat statistik penggunaan:
   - Waktu penggunaan aplikasi
   - Progress challenge
   - Streak hari
   - Poin yang didapat

### D. Mencairkan Reward

1. Buka tab **Reward**
2. Lihat daftar achievement yang sudah didapat
3. Lihat poin yang terkumpul
4. Gunakan poin untuk menukar reward (jika tersedia)

### E. Membuka Aplikasi yang Diblokir

**Untuk sementara membuka aplikasi:**

1. Buka tab **Challenge**
2. Di bagian **"Diblokir"**, cari aplikasi yang ingin dibuka
3. Tap tombol **"Buka"** (hijau)
4. Aplikasi akan dihapus dari daftar block
5. Sekarang aplikasi bisa dibuka normal

**Untuk memblokir lagi:**

1. Di bagian **"Aktif"**, cari aplikasi yang ingin diblokir
2. Tap tombol **"Blokir"** (merah)
3. Aplikasi akan diblokir lagi

---

## 🔧 5. Troubleshooting

### Masalah: Dialog "Aktifkan Accessibility Service" Muncul Terus

**Penyebab:** Accessibility Service belum diaktifkan di Settings Android

**Solusi:**
1. Tap **"Aktifkan"** pada dialog
2. Di Settings → Accessibility, cari **"Detox Social Media"**
3. Aktifkan toggle
4. Kembali ke aplikasi
5. Dialog tidak akan muncul lagi

### Masalah: Aplikasi Masih Bisa Dibuka Meskipun Sudah Diblokir

**Penyebab:** Accessibility Service tidak aktif atau blocking tidak enabled

**Solusi:**
1. **Cek Accessibility Service:**
   - Settings → Accessibility → Detox Social Media
   - Pastikan toggle **ON**

2. **Cek Toggle di Aplikasi:**
   - Pastikan toggle **"Detox Social Media"** **ON**

3. **Restart Aplikasi:**
   - Force close aplikasi Detox Social Media
   - Buka kembali

4. **Cek Log (untuk developer):**
   - Gunakan `adb logcat | grep AppBlockingService`
   - Lihat apakah ada error atau warning

### Masalah: Toggle "Detox Social Media" Tidak Bisa Diaktifkan

**Penyebab:** Accessibility Service belum aktif

**Solusi:**
1. Aktifkan Accessibility Service terlebih dahulu (lihat Langkah 1)
2. Setelah service aktif, toggle bisa diaktifkan

### Masalah: Aplikasi Tidak Muncul di Daftar Block

**Penyebab:** Aplikasi tidak didukung atau package name tidak sesuai

**Solusi:**
1. Pastikan aplikasi yang ingin diblokir didukung
2. Aplikasi yang didukung:
   - Instagram (`com.instagram.android`)
   - TikTok (`com.zhiliaoapp.musically`)
   - Facebook (`com.facebook.katana`)
   - Twitter/X (`com.twitter.android`)
   - YouTube (`com.google.android.youtube`)
   - Snapchat (`com.snapchat.android`)
   - Dan lainnya (lihat `AppPackageMapping`)

---

## 📱 6. Fitur-Fitur Utama

### Dashboard
- **Check-in harian:** Tap tombol check-in untuk mencatat progress
- **Streak counter:** Lihat berapa hari berturut-turut check-in
- **Quick stats:** Lihat ringkasan progress challenge

### Challenge
- **Buat challenge:** Pilih aplikasi dan durasi
- **Blokir/Buka aplikasi:** Kelola aplikasi yang diblokir
- **Progress tracking:** Lihat progress challenge aktif

### Analytics
- **Usage statistics:** Lihat waktu penggunaan aplikasi
- **Progress charts:** Grafik progress harian/mingguan
- **Achievement tracking:** Lihat achievement yang sudah didapat

### Reward
- **Points system:** Kumpulkan poin dari aktivitas
- **Achievements:** Dapatkan achievement untuk milestone
- **Leaderboard:** Lihat ranking pengguna lain

### Profile
- **Edit profil:** Ubah nama, foto, dll
- **Settings:** Atur notifikasi, reminder, dll
- **Logout:** Keluar dari akun

---

## 🎓 7. Tips Penggunaan

### Tips 1: Aktifkan Notifikasi Reminder
- Buka **Profile** → **Settings** → **Reminder**
- Aktifkan reminder untuk check-in harian
- Akan membantu menjaga streak

### Tips 2: Gunakan Challenge Bertahap
- Mulai dengan challenge 3 hari
- Setelah berhasil, tingkatkan ke 7 hari
- Jangan langsung challenge 30 hari

### Tips 3: Blokir Aplikasi Secara Bertahap
- Jangan langsung blokir semua aplikasi
- Mulai dengan 1-2 aplikasi yang paling sering digunakan
- Setelah terbiasa, tambahkan aplikasi lain

### Tips 4: Gunakan Fitur Journal
- Catat mood dan perasaan setiap hari
- Membantu refleksi dan motivasi
- Dapat poin tambahan

### Tips 5: Cek Progress Secara Rutin
- Buka tab **Analytics** setiap beberapa hari
- Lihat progress dan achievement
- Gunakan sebagai motivasi

---

## ⚠️ 8. Catatan Penting

### Keamanan
- **Accessibility Service aman:** Permission ini hanya digunakan untuk mendeteksi aplikasi yang dibuka, bukan untuk mengakses data pribadi
- **Data tidak dikirim:** Semua data disimpan lokal di device
- **Tidak ada tracking:** Aplikasi tidak melacak aktivitas di aplikasi lain

### Kompatibilitas
- **Android 5.0+:** Aplikasi memerlukan Android Lollipop atau lebih baru
- **Tidak untuk iOS:** Fitur blocking hanya tersedia di Android
- **Beberapa device:** Mungkin ada perbedaan behavior di beberapa device/manufacturer

### Performance
- **Battery usage:** Accessibility Service menggunakan sedikit battery
- **Background running:** Aplikasi harus berjalan di background untuk blocking berfungsi
- **Memory:** Service menggunakan memory minimal

---

## 📞 9. Bantuan

Jika mengalami masalah yang tidak teratasi:

1. **Cek dokumentasi:**
   - `CARA_AKTIFKAN_BLOCKING.md` - Panduan mengaktifkan blocking
   - `BUILD_ANDROID.md` - Panduan build APK
   - `APP_BLOCKING_SETUP.md` - Setup teknis blocking

2. **Cek log aplikasi:**
   - Gunakan `adb logcat` untuk melihat log
   - Filter dengan `AppBlockingService` atau `MainActivity`

3. **Restart device:**
   - Kadang restart device bisa menyelesaikan masalah

4. **Reinstall aplikasi:**
   - Uninstall aplikasi
   - Install ulang APK
   - Setup ulang dari awal

---

## ✅ 10. Checklist Setup

Gunakan checklist ini untuk memastikan semua sudah benar:

- [ ] APK sudah terinstall
- [ ] Sudah login/register
- [ ] Accessibility Service sudah aktif di Settings → Accessibility
- [ ] Toggle "Detox Social Media" ON di aplikasi
- [ ] Sudah memblokir minimal 1 aplikasi
- [ ] Sudah test membuka aplikasi yang diblokir (harus tertutup)
- [ ] Notifikasi reminder sudah diaktifkan (opsional)
- [ ] Challenge sudah dibuat (opsional)

---

**Selamat menggunakan aplikasi Detox Social Media! 🎉**

Dengan menggunakan aplikasi ini secara konsisten, Anda akan terbantu untuk mengurangi ketergantungan pada media sosial dan fokus pada tujuan detox Anda.

