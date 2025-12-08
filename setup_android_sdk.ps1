# Script untuk setup Android SDK path
Write-Host "=== Setup Android SDK Path ===" -ForegroundColor Cyan

# Lokasi umum Android SDK
$possiblePaths = @(
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:USERPROFILE\AppData\Local\Android\Sdk",
    "C:\Android\sdk",
    "C:\Program Files\Android\Sdk",
    "C:\Program Files (x86)\Android\android-sdk"
)

Write-Host "`nMencari Android SDK..." -ForegroundColor Yellow

$foundSdk = $null
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $platformTools = Join-Path $path "platform-tools\adb.exe"
        if (Test-Path $platformTools) {
            Write-Host "✓ Android SDK ditemukan di: $path" -ForegroundColor Green
            $foundSdk = $path
            break
        }
    }
}

if ($foundSdk -eq $null) {
    Write-Host "`n❌ Android SDK tidak ditemukan!" -ForegroundColor Red
    Write-Host "`nSilakan install Android Studio atau Android SDK terlebih dahulu." -ForegroundColor Yellow
    Write-Host "Panduan lengkap ada di file: ANDROID_SDK_SETUP.md" -ForegroundColor Yellow
    Write-Host "`nAtau masukkan path Android SDK secara manual:" -ForegroundColor Cyan
    $manualPath = Read-Host "Masukkan path Android SDK"
    if ($manualPath -and (Test-Path $manualPath)) {
        $foundSdk = $manualPath
    } else {
        Write-Host "Path tidak valid atau tidak ditemukan!" -ForegroundColor Red
        exit 1
    }
}

# Update local.properties
$sdkPath = $foundSdk.Replace('\', '\\')
$localPropertiesPath = "android\local.properties"

$content = @"
sdk.dir=$sdkPath
flutter.sdk=C:\\flutter
flutter.buildMode=release
flutter.versionName=1.0.0
flutter.versionCode=1
"@

Set-Content -Path $localPropertiesPath -Value $content
Write-Host "`n✓ File local.properties sudah di-update!" -ForegroundColor Green
Write-Host "Path SDK: $foundSdk" -ForegroundColor Cyan

Write-Host "`nSekarang coba build APK lagi dengan:" -ForegroundColor Yellow
Write-Host "  flutter build apk --release" -ForegroundColor White
