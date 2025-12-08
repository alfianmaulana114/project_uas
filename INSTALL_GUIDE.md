# 📱 Panduan Install APK - Detox Social Media

## ⚠️ Catatan Penting

Aplikasi ini menggunakan **Accessibility Service** untuk fitur blocking aplikasi. Google Play Protect mungkin memblokir instalasi karena permission ini dianggap sensitif. Ini adalah **perilaku normal** untuk aplikasi yang menggunakan Accessibility Service.

## 🔧 Cara Install APK

### Metode 1: Install dengan Menonaktifkan Play Protect Sementara (RECOMMENDED)

1. **Buka Settings** → **Security** → **Google Play Protect**
2. **Nonaktifkan** "Scan apps with Play Protect" sementara
3. **Install APK** dari file manager atau WhatsApp
4. Setelah install berhasil, Anda bisa mengaktifkan kembali Play Protect

### Metode 2: Install via ADB (Untuk Developer)

```bash
adb install app-release.apk
```

### Metode 3: Install dengan Mengizinkan Sumber Tidak Dikenal

1. **Buka Settings** → **Security** → **Install unknown apps**
2. Pilih aplikasi yang akan digunakan untuk install (File Manager, WhatsApp, dll)
3. **Aktifkan** "Allow from this source"
4. Install APK

### Metode 4: Install Langsung dari File Manager

1. Buka **File Manager**
2. Cari file `app-release.apk`
3. Tap file APK
4. Jika muncul peringatan Play Protect:
   - Tap **"Install anyway"** atau **"Tetap install"**
   - Atau tap **"More details"** → **"Install anyway"**

## 🛡️ Mengapa Play Protect Memperingatkan?

Play Protect memperingatkan karena aplikasi ini menggunakan:
- **Accessibility Service** - Untuk mendeteksi dan memblokir aplikasi
- Permission ini diperlukan untuk fitur blocking bekerja dengan baik

**Ini adalah permission yang aman** dan hanya digunakan untuk:
- Mendeteksi aplikasi yang dibuka
- Menampilkan layar blocking
- Tidak mengakses data pribadi atau mengirim data ke server

## ✅ Setelah Install

1. Buka aplikasi **Detox Social Media**
2. Saat pertama kali menggunakan fitur blocking, aplikasi akan meminta:
   - **Accessibility Service** - Aktifkan di Settings → Accessibility
   - **Overlay Permission** (opsional) - Untuk layar blocking yang lebih baik
3. Ikuti petunjuk di aplikasi untuk setup

## 🔒 Keamanan

- Aplikasi ini **tidak mengirim data** ke server pihak ketiga
- Semua data disimpan lokal di perangkat
- Accessibility Service hanya digunakan untuk fitur blocking
- Tidak ada tracking atau pengumpulan data pribadi

## ❓ Troubleshooting

### "Aplikasi tidak terinstall"
- Pastikan "Install unknown apps" sudah diaktifkan
- Nonaktifkan Play Protect sementara
- Coba install via ADB

### "Aplikasi diblokir oleh Play Protect"
- Ini normal untuk aplikasi dengan Accessibility Service
- Tap "Install anyway" atau nonaktifkan Play Protect sementara
- Aplikasi aman untuk digunakan

### "Parse error" saat install
- Pastikan file APK tidak corrupt
- Download ulang file APK
- Pastikan perangkat Android mendukung (min Android 5.0)

## 📞 Bantuan

Jika masih ada masalah, pastikan:
1. Perangkat Android versi 5.0 (Lollipop) atau lebih baru
2. Memiliki cukup ruang penyimpanan
3. File APK tidak corrupt

