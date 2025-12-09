# Script untuk build Android APK
# Penggunaan: .\build_android.ps1 [release|debug]

param(
    [string]$BuildType = "release"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build Android APK - Project UAS" -ForegroundColor Cyan
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

# Clean build sebelumnya
Write-Host "Membersihkan build sebelumnya..." -ForegroundColor Yellow
flutter clean
Write-Host ""

# Get dependencies
Write-Host "Mengambil dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

# Build APK
Write-Host "Membangun APK ($BuildType)..." -ForegroundColor Yellow
Write-Host ""

if ($BuildType -eq "release") {
    flutter build apk --release
} else {
    flutter build apk --debug
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Build berhasil!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    $apkPath = "build\app\outputs\flutter-apk\app-$BuildType.apk"
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        Write-Host "APK Location: $apkPath" -ForegroundColor Cyan
        Write-Host "APK Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "File APK siap untuk diinstall ke Android device!" -ForegroundColor Green
    } else {
        Write-Host "Warning: File APK tidak ditemukan di lokasi yang diharapkan." -ForegroundColor Yellow
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

