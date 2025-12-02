# Setup Logo Aplikasi "Detox Social Media"

## 📋 Overview

File ini menjelaskan cara mengganti logo aplikasi dengan logo baru "Detox Social Media".

## 🎨 Deskripsi Logo

Logo yang diinginkan:
- **Bentuk**: Kotak dengan sudut membulat (rounded square)
- **Warna Background**: Orange gelap (dark orange/burnt orange)
- **Icon**: Smartphone dengan chat bubble yang berisi simbol 'X'
- **Warna Icon**: Orange terang/beige
- **Text**: "DETOX" (besar, bold) dan "SOCIAL MEDIA" (kecil, uppercase)
- **Warna Text**: Orange gelap

## 📱 Langkah-langkah Setup Logo

### Untuk Android:

1. **Siapkan file logo**:
   - Buat file logo dengan ukuran yang sesuai
   - Format: PNG dengan background transparan
   - Ukuran yang diperlukan:
     - `ic_launcher.png` (1024x1024 px) - untuk semua density

2. **Generate icon untuk semua density**:
   - Gunakan tool online seperti [App Icon Generator](https://www.appicon.co/) atau [Icon Kitchen](https://icon.kitchen/)
   - Upload logo 1024x1024 px
   - Download semua ukuran yang dihasilkan

3. **Ganti file logo**:
   - Ganti file di folder berikut:
     - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48 px)
     - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72 px)
     - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96 px)
     - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144 px)
     - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192 px)

### Untuk iOS:

1. **Siapkan file logo**:
   - Buat file logo dengan ukuran yang sesuai
   - Format: PNG dengan background transparan
   - Ukuran: 1024x1024 px

2. **Ganti file logo**:
   - Ganti file di folder:
     - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Ganti semua ukuran yang ada di folder tersebut

## 🛠️ Alternatif: Menggunakan Flutter Launcher Icons

Jika Anda sudah punya file logo, bisa menggunakan package `flutter_launcher_icons`:

1. **Install package** (tambahkan ke `dev_dependencies` di `pubspec.yaml`):
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.1
   ```

2. **Tambahkan konfigurasi** di `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/logo/app_icon.png"  # Path ke logo Anda
     adaptive_icon_background: "#FF6B35"  # Warna background (orange)
     adaptive_icon_foreground: "assets/logo/app_icon_foreground.png"
   ```

3. **Jalankan command**:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

## 📝 Catatan

- Pastikan file logo memiliki background transparan atau sesuai dengan desain
- Ukuran file logo harus sesuai dengan requirement masing-masing platform
- Setelah mengganti logo, rebuild aplikasi untuk melihat perubahan

## ✅ Checklist

- [ ] File logo sudah disiapkan (1024x1024 px)
- [ ] Logo sudah diganti di semua folder Android (5 ukuran)
- [ ] Logo sudah diganti di folder iOS
- [ ] Aplikasi sudah di-rebuild
- [ ] Logo sudah muncul di aplikasi

Setelah semua selesai, logo baru akan muncul di aplikasi! 🎨

