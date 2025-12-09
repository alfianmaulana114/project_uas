# 🚫 Cara Mengaktifkan App Blocking - PENTING!

## ⚠️ MASALAH: Aplikasi Masih Bisa Dibuka Meskipun Sudah Diblokir?

**PENYEBAB UTAMA:** Accessibility Service belum diaktifkan di Settings Android!

Toggle di aplikasi hanya mengaktifkan **logika blocking**, tapi **Accessibility Service** harus diaktifkan **secara manual** di Settings Android agar blocking benar-benar berfungsi.

---

## ✅ LANGKAH-LANGKAH MENGAKTIFKAN (WAJIB DILAKUKAN):

### Langkah 1: Buka Settings Android
1. Buka **Settings** (Pengaturan) di Android Anda
2. Scroll ke bawah, cari dan tap **"Accessibility"** (Aksesibilitas)
   - Atau cari di search bar: "Accessibility"

### Langkah 2: Cari "Detox Social Media"
1. Di halaman Accessibility, scroll ke bawah
2. Cari **"Detox Social Media"** atau **"AppBlockingService"** dalam daftar
3. Tap pada item tersebut

### Langkah 3: Aktifkan Service
1. Anda akan melihat toggle switch
2. **Aktifkan toggle** (geser ke kanan/ON)
3. Akan muncul dialog konfirmasi - tap **"Allow"** atau **"Izinkan"**

### Langkah 4: Kembali ke Aplikasi
1. Kembali ke aplikasi **Detox Social Media**
2. Pastikan toggle **"Detox Social Media"** sudah ON di aplikasi
3. Pilih aplikasi yang ingin diblokir (Instagram, TikTok, dll)
4. Coba buka aplikasi yang diblokir - seharusnya langsung tertutup!

---

## 🔍 Cara Cek Apakah Sudah Aktif:

### Di Aplikasi:
- Buka aplikasi Detox Social Media
- Lihat status Accessibility Service
- Jika sudah aktif, akan muncul tanda centang hijau ✅

### Di Settings Android:
- Settings → Accessibility
- Cari "Detox Social Media"
- Toggle harus dalam posisi **ON** (hijau/aktif)

---

## 🐛 Masalah yang Sering Terjadi:

### 1. "Aplikasi masih bisa dibuka"
**Solusi:**
- ✅ Pastikan Accessibility Service sudah aktif di Settings → Accessibility
- ✅ Restart aplikasi Detox Social Media
- ✅ Pastikan toggle "Detox Social Media" ON di aplikasi
- ✅ Pastikan aplikasi sudah ditambahkan ke daftar block

### 2. "Accessibility Service tidak muncul di Settings"
**Solusi:**
- ✅ Pastikan aplikasi sudah terinstall dengan benar
- ✅ Restart device Android
- ✅ Cek di Settings → Apps → Detox Social Media → App details → Additional settings

### 3. "Toggle di aplikasi tidak bisa diaktifkan"
**Solusi:**
- ✅ Aktifkan Accessibility Service terlebih dahulu di Settings Android
- ✅ Setelah Accessibility Service aktif, baru toggle di aplikasi bisa diaktifkan

---

## 📱 Screenshot Lokasi Settings:

**Path lengkap:**
```
Settings (Pengaturan)
  → Accessibility (Aksesibilitas)
    → Detox Social Media
      → Toggle ON
```

**Atau via search:**
- Buka Settings
- Ketik "Accessibility" di search bar
- Tap hasil pertama
- Cari "Detox Social Media"

---

## ⚡ Quick Fix:

Jika aplikasi masih bisa dibuka setelah semua langkah di atas:

1. **Nonaktifkan** toggle "Detox Social Media" di aplikasi
2. **Nonaktifkan** Accessibility Service di Settings → Accessibility
3. **Restart** aplikasi Detox Social Media
4. **Aktifkan kembali** Accessibility Service di Settings
5. **Aktifkan kembali** toggle di aplikasi
6. **Coba lagi** buka aplikasi yang diblokir

---

## 📝 Catatan Penting:

- ⚠️ **Accessibility Service WAJIB diaktifkan** untuk blocking berfungsi
- ⚠️ Toggle di aplikasi saja **TIDAK CUKUP** - harus aktifkan di Settings Android juga
- ✅ Setelah Accessibility Service aktif, blocking akan bekerja otomatis
- ✅ Tidak perlu restart device setelah mengaktifkan
- ✅ Service akan berjalan di background secara otomatis

---

## 🆘 Masih Tidak Berfungsi?

Jika setelah semua langkah di atas aplikasi masih bisa dibuka:

1. Cek log aplikasi (jika punya akses developer)
2. Pastikan package name aplikasi yang diblokir sudah benar
3. Coba uninstall dan install ulang aplikasi Detox Social Media
4. Pastikan Android version Anda mendukung Accessibility Service (Android 5.0+)

---

**Ingat:** Accessibility Service adalah permission yang aman dan hanya digunakan untuk mendeteksi aplikasi yang dibuka, bukan untuk mengakses data pribadi Anda.

