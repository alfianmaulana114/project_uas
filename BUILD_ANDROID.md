# Panduan Build Android untuk Project UAS

Panduan ini menjelaskan cara mengekspor aplikasi Flutter ke Android dalam format APK atau AAB.

## Opsi Build

### 1. Build APK (Untuk Testing/Instalasi Langsung)

APK cocok untuk:
- Testing di device fisik
- Distribusi langsung (sideload)
- Instalasi manual tanpa Google Play Store

**Cara build APK:**

```powershell
# Build APK Release
.\build_android.ps1 release

# Atau build APK Debug
.\build_android.ps1 debug
```

**Atau menggunakan Flutter CLI langsung:**
```powershell
flutter build apk --release
```

File APK akan berada di: `build\app\outputs\flutter-apk\app-release.apk`

### 2. Build AAB (Untuk Google Play Store)

AAB (Android App Bundle) adalah format yang diperlukan untuk upload ke Google Play Store.

**Cara build AAB:**
```powershell
.\build_android_aab.ps1
```

**Atau menggunakan Flutter CLI langsung:**
```powershell
flutter build appbundle --release
```

File AAB akan berada di: `build\app\outputs\bundle\release\app-release.aab`

## Setup Release Signing (Opsional tapi Direkomendasikan)

Untuk production build, Anda sebaiknya menggunakan keystore sendiri daripada debug keystore.

### Langkah 1: Buat Keystore

Jalankan perintah berikut di terminal (PowerShell atau Command Prompt):

```powershell
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Anda akan diminta untuk:
- Password keystore (simpan dengan aman!)
- Password key (bisa sama dengan keystore password)
- Informasi identitas (nama, organisasi, dll)

**PENTING:** Simpan password dan file keystore dengan aman! Jika hilang, Anda tidak bisa update aplikasi di Play Store.

### Langkah 2: Buat File key.properties

1. Copy template:
   ```powershell
   Copy-Item android\key.properties.template android\key.properties
   ```

2. Edit file `android/key.properties` dan isi dengan informasi keystore Anda:
   ```
   storePassword=password_keystore_anda
   keyPassword=password_key_anda
   keyAlias=upload
   storeFile=../app/upload-keystore.jks
   ```

3. **JANGAN commit file `key.properties` ke git!** File ini sudah otomatis di-ignore oleh `.gitignore`.

### Langkah 3: Build dengan Signing

Setelah setup keystore, build release akan otomatis menggunakan keystore Anda:

```powershell
.\build_android.ps1 release
# atau
.\build_android_aab.ps1
```

## Troubleshooting

### Error: "Flutter tidak ditemukan"
- Pastikan Flutter sudah terinstall dan ada di PATH
- Cek dengan: `flutter --version`

### Error: "Gradle build failed"
- Pastikan Android SDK sudah terinstall
- Cek file `android/local.properties` apakah path SDK sudah benar
- Coba: `flutter doctor` untuk melihat masalah

### Error: "Keystore tidak ditemukan"
- Pastikan file `android/app/upload-keystore.jks` ada
- Pastikan path di `key.properties` benar (relatif dari `android/` folder)

### APK terlalu besar
- Build split APK untuk mengurangi ukuran per device:
  ```powershell
  flutter build apk --split-per-abi
  ```
  Ini akan menghasilkan 3 file APK terpisah untuk arsitektur berbeda (armeabi-v7a, arm64-v8a, x86_64)

## Instalasi APK ke Device

1. **Via USB:**
   - Aktifkan USB Debugging di device Android
   - Hubungkan device ke PC
   - Jalankan: `flutter install` atau `adb install build\app\outputs\flutter-apk\app-release.apk`

2. **Via File Transfer:**
   - Copy file APK ke device (via USB, email, cloud storage, dll)
   - Buka file APK di device
   - Izinkan instalasi dari sumber tidak dikenal jika diminta

## Upload ke Google Play Store

1. Login ke [Google Play Console](https://play.google.com/console)
2. Buat aplikasi baru atau pilih aplikasi yang sudah ada
3. Di bagian "Release" > "Production" (atau "Testing")
4. Upload file AAB yang sudah di-build
5. Isi informasi yang diperlukan (screenshots, deskripsi, dll)
6. Submit untuk review

## Catatan Penting

- **Version Code & Version Name:** Diatur di `pubspec.yaml` (field `version`)
- **Application ID:** Saat ini `com.example.project_uas` - ubah jika perlu di `android/app/build.gradle.kts`
- **Min SDK:** Diatur oleh Flutter, biasanya Android 5.0 (API 21) atau lebih tinggi
- **Target SDK:** Harus selalu update ke versi terbaru untuk kompatibilitas

## Referensi

- [Flutter Build & Release Documentation](https://docs.flutter.dev/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Google Play Console](https://play.google.com/console)

