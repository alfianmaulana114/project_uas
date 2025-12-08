# 🔧 Setup Android SDK untuk Build APK

## ⚠️ Error yang Terjadi
```
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

## 📋 Solusi

### Opsi 1: Install Android Studio (Recommended)
1. Download Android Studio dari: https://developer.android.com/studio
2. Install Android Studio
3. Saat pertama kali buka, Android Studio akan otomatis download Android SDK
4. Lokasi default SDK biasanya di: `C:\Users\<Username>\AppData\Local\Android\Sdk`

### Opsi 2: Install Android SDK Command Line Tools
1. Download Android SDK Command Line Tools dari: https://developer.android.com/studio#command-tools
2. Extract ke folder (misalnya: `C:\Android\sdk`)
3. Jalankan `sdkmanager` untuk install platform tools

### Opsi 3: Update local.properties (Jika SDK sudah ada)
Jika Android SDK sudah terinstall di lokasi lain, update file `android/local.properties`:

```properties
sdk.dir=C:\\Users\\<Username>\\AppData\\Local\\Android\\Sdk
```

Atau jika di lokasi lain, sesuaikan path-nya.

## 🔍 Cara Cek Lokasi Android SDK

1. **Jika menggunakan Android Studio:**
   - Buka Android Studio
   - File → Settings → Appearance & Behavior → System Settings → Android SDK
   - Lihat "Android SDK Location"

2. **Lokasi default umum:**
   - `C:\Users\<Username>\AppData\Local\Android\Sdk`
   - `C:\Android\sdk`
   - `%LOCALAPPDATA%\Android\Sdk`

## ✅ Setelah SDK Terinstall

1. Update file `android/local.properties` dengan path SDK yang benar
2. Atau set environment variable `ANDROID_HOME`:
   ```powershell
   [System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\<Username>\AppData\Local\Android\Sdk', 'User')
   ```
3. Restart terminal/PowerShell
4. Coba build lagi: `flutter build apk --release`

## 🚀 Quick Fix (Jika SDK sudah ada)

Jika Anda sudah punya Android SDK di lokasi tertentu, jalankan command ini untuk update `local.properties`:

```powershell
# Ganti <SDK_PATH> dengan path SDK Anda
$sdkPath = "C:\Users\<Username>\AppData\Local\Android\Sdk"
$content = "sdk.dir=$($sdkPath.Replace('\', '\\'))`nflutter.sdk=C:\\flutter`nflutter.buildMode=release`nflutter.versionName=1.0.0`nflutter.versionCode=1"
Set-Content -Path "android\local.properties" -Value $content
```
