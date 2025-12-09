# Script untuk build Android App Bundle (AAB) untuk Google Play Store
# Penggunaan: .\build_android_aab.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build Android AAB - Project UAS" -ForegroundColor Cyan
Write-Host "  (Untuk Google Play Store)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Cek apakah Flutter sudah terinstall
Write-Host "Memeriksa Flutter installation..." -ForegroundColor Yellow
$flutterCheck = flutter --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter tidak ditemukan. Pastikan Flutter sudah terinstall dan ada di PATH." -ForegroundColor Red
    exit 1
}
Write-Host "Flutter ditemukan!" -ForegroundColor Green
Write-Host ""

# Cek apakah key.properties ada untuk release signing
$keyPropertiesPath = "android\key.properties"
if (-not (Test-Path $keyPropertiesPath)) {
    Write-Host "WARNING: File key.properties tidak ditemukan!" -ForegroundColor Yellow
    Write-Host "Build akan menggunakan debug signing (tidak cocok untuk production)." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Untuk membuat key.properties, jalankan:" -ForegroundColor Cyan
    Write-Host "  1. Buat keystore: keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload" -ForegroundColor Cyan
    Write-Host "  2. Edit android/key.properties dengan informasi keystore" -ForegroundColor Cyan
    Write-Host ""
    $continue = Read-Host "Lanjutkan dengan debug signing? (y/n)"
    if ($continue -ne "y") {
        exit 0
    }
    Write-Host ""
}

# Clean build sebelumnya
Write-Host "Membersihkan build sebelumnya..." -ForegroundColor Yellow
flutter clean
Write-Host ""

# Get dependencies
Write-Host "Mengambil dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

# Build AAB
Write-Host "Membangun App Bundle (AAB)..." -ForegroundColor Yellow
Write-Host ""

flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Build berhasil!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    $aabPath = "build\app\outputs\bundle\release\app-release.aab"
    if (Test-Path $aabPath) {
        $aabSize = (Get-Item $aabPath).Length / 1MB
        Write-Host "AAB Location: $aabPath" -ForegroundColor Cyan
        Write-Host "AAB Size: $([math]::Round($aabSize, 2)) MB" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "File AAB siap untuk diupload ke Google Play Console!" -ForegroundColor Green
    } else {
        Write-Host "Warning: File AAB tidak ditemukan di lokasi yang diharapkan." -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  Build gagal!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Periksa error di atas untuk detail lebih lanjut." -ForegroundColor Yellow
    exit 1
}

