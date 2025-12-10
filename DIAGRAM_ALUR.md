# 📊 Diagram Alur Penggunaan Aplikasi

Diagram visual untuk memahami alur penggunaan aplikasi Detox Social Media.

---

## 🔄 Alur Setup Awal

```
┌─────────────────────────────────────────────────────────────┐
│                   1. INSTALL APK                             │
│   Transfer APK → Install → Open App                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   2. LOGIN/REGISTER                         │
│   Masukkan Email & Password → Login                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   3. DASHBOARD                               │
│   Halaman utama aplikasi                                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   4. SETUP BLOCKING                          │
│   Challenge Tab → Blokir App → Dialog Muncul                │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   5. AKTIFKAN ACCESSIBILITY                  │
│   Tap "Aktifkan" → Settings → Accessibility                 │
│   → Cari "Detox Social Media" → Toggle ON                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   6. KEMBALI KE APLIKASI                     │
│   Toggle "Detox Social Media" ON                            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   7. BLOKIR APLIKASI                         │
│   Challenge → Tap "Blokir" → App ditambahkan               │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   8. TEST BLOCKING                          │
│   Buka App yang diblokir → Harus tertutup! ✅              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Alur Blokir Aplikasi

```
┌─────────────────────────────────────────────────────────────┐
│              USER MEMBUKA APLIKASI YANG DIBLOKIR            │
│              (contoh: Instagram, TikTok)                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│         AppBlockingService MENDETEKSI APLIKASI              │
│         (via Accessibility Event)                            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│         CEK: Apakah package name ada di daftar block?       │
└──────┬──────────────────────────────────────────┬──────────┘
       │                                          │
       │ YA                                        │ TIDAK
       ▼                                          ▼
┌──────────────────────┐              ┌──────────────────────┐
│  APLIKASI DIBLOKIR   │              │  APLIKASI DIBUKA     │
│                      │              │  NORMAL              │
└──────────┬───────────┘              └──────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│         TUTUP APLIKASI                                      │
│         - performGlobalAction(BACK)                         │
│         - performGlobalAction(HOME)                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│         TAMPILKAN LAYAR BLOCKING                            │
│         - BlockingOverlayActivity                           │
│         - Toast Notification                                │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Alur Check-in Harian

```
┌─────────────────────────────────────────────────────────────┐
│                    USER BUKA APLIKASI                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    DASHBOARD                                │
│              (Halaman Utama)                                │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              TAP TOMBOL "CHECK-IN"                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              CEK: Sudah check-in hari ini?                  │
└──────┬──────────────────────────────────────────┬──────────┘
       │                                          │
       │ BELUM                                    │ SUDAH
       ▼                                          ▼
┌──────────────────────┐              ┌──────────────────────┐
│  PROSES CHECK-IN     │              │  NOTIFIKASI:         │
│  - Simpan data       │              │  "Sudah check-in"    │
│  - Update streak     │              │                      │
│  - Tambah poin       │              └──────────────────────┘
└──────────┬───────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│              CELEBRATION / NOTIFIKASI                        │
│              "Check-in berhasil! Streak: X hari"            │
└─────────────────────────────────────────────────────────────┘
```

---

## 📱 Alur Challenge

```
┌─────────────────────────────────────────────────────────────┐
│                    TAB CHALLENGE                            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              PILIH AKSI:                                     │
│  1. Buat Challenge Baru                                     │
│  2. Blokir/Buka Aplikasi                                   │
│  3. Lihat Progress Challenge                                │
└──────┬──────────────────────────────────────────┬──────────┘
       │                                          │
       │ BLOKIR APLIKASI                          │ BUAT CHALLENGE
       ▼                                          ▼
┌──────────────────────┐              ┌──────────────────────┐
│  CEK: Accessibility  │              │  PILIH APLIKASI      │
│  Service aktif?       │              │  PILIH DURASI       │
└──────┬───────────────┘              └──────────┬───────────┘
       │                                          │
       │ YA                                        │
       ▼                                          ▼
┌──────────────────────┐              ┌──────────────────────┐
│  TAMBAH KE DAFTAR    │              │  BUAT CHALLENGE      │
│  BLOCK                │              │  - Set durasi        │
│  - Update service     │              │  - Blokir apps       │
│  - Notifikasi        │              │  - Start tracking    │
└──────────────────────┘              └──────────────────────┘
```

---

## 🔍 Alur Deteksi & Blocking (Detail Teknis)

```
┌─────────────────────────────────────────────────────────────┐
│         AppBlockingService BERJALAN DI BACKGROUND          │
│         (Accessibility Service)                             │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│         MONITORING SETIAP 50ms                               │
│         - checkCurrentApp()                                  │
│         - onAccessibilityEvent()                              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│         DETEKSI APLIKASI YANG DIBUKA                        │
│         - rootInActiveWindow.packageName                     │
│         - event.packageName                                  │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│         CEK: packageName ada di blockedPackages?            │
└──────┬──────────────────────────────────────────┬──────────┘
       │                                          │
       │ YA                                        │ TIDAK
       ▼                                          ▼
┌──────────────────────┐              ┌──────────────────────┐
│  CEK: isBlocking     │              │  LANJUTKAN MONITORING │
│  Enabled?            │              │  (tidak ada aksi)     │
└──────┬───────────────┘              └──────────────────────┘
       │
       │ YA
       ▼
┌─────────────────────────────────────────────────────────────┐
│         BLOKIR APLIKASI                                      │
│         1. performGlobalAction(BACK)                         │
│         2. performGlobalAction(HOME)                        │
│         3. Tampilkan BlockingOverlayActivity                │
│         4. Tampilkan Toast Notification                      │
│         5. Monitoring berkelanjutan                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎓 Alur Belajar Pengguna Baru

```
┌─────────────────────────────────────────────────────────────┐
│                    PENGguna BARU                            │
│              (First Time User)                              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    INSTALL & LOGIN                          │
│              (Step 1-2 dari Quick Start)                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    EKSPLORASI APLIKASI                       │
│   - Dashboard: Lihat overview                              │
│   - Challenge: Lihat fitur blocking                        │
│   - Analytics: Lihat statistik                             │
│   - Reward: Lihat achievement                               │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    COBA FITUR BLOCKING                       │
│   - Tap "Blokir" pada aplikasi                             │
│   - Ikuti dialog untuk aktifkan Accessibility               │
│   - Setup selesai                                           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    GUNAKAN SECARA RUTIN                     │
│   - Check-in setiap hari                                    │
│   - Monitor progress                                        │
│   - Dapatkan reward                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚠️ Alur Troubleshooting

```
┌─────────────────────────────────────────────────────────────┐
│                    MASALAH TERDETEKSI                       │
│         (Aplikasi masih bisa dibuka)                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    CEK 1: Accessibility Service            │
│         Settings → Accessibility → Detox Social Media       │
└──────┬──────────────────────────────────────────┬──────────┘
       │                                          │
       │ TIDAK AKTIF                              │ AKTIF
       ▼                                          ▼
┌──────────────────────┐              ┌──────────────────────┐
│  AKTIFKAN SERVICE    │              │  CEK 2: Toggle ON?   │
│  Kembali ke app      │              └──────┬───────────────┘
└──────────────────────┘                     │
                                              │
                                              ▼
                              ┌───────────────────────────────┐
                              │  CEK 3: App di daftar block?  │
                              └──────┬───────────────────────┘
                                     │
                                     ▼
                              ┌───────────────────────────────┐
                              │  CEK 4: Restart App           │
                              │  Force close → Buka lagi      │
                              └───────────────────────────────┘
```

---

## 📊 State Diagram - Status Blocking

```
                    ┌─────────────┐
                    │   INACTIVE  │
                    │  (Default)  │
                    └──────┬──────┘
                           │
                           │ User aktifkan
                           │ Accessibility Service
                           ▼
                    ┌─────────────┐
                    │  SERVICE    │
                    │   ACTIVE    │
                    └──────┬──────┘
                           │
                           │ User aktifkan
                           │ toggle di app
                           ▼
                    ┌─────────────┐
                    │  BLOCKING   │
                    │   ENABLED   │
                    └──────┬──────┘
                           │
                           │ User blokir
                           │ aplikasi
                           ▼
                    ┌─────────────┐
                    │   APPS      │
                    │  BLOCKED    │
                    └─────────────┘
```

---

## 🔄 Flowchart Lengkap - Setup Blocking

```
                    START
                      │
                      ▼
              ┌───────────────┐
              │ Install APK   │
              └───────┬───────┘
                      │
                      ▼
              ┌───────────────┐
              │ Login/Register│
              └───────┬───────┘
                      │
                      ▼
              ┌───────────────┐
              │  Buka Challenge│
              └───────┬───────┘
                      │
                      ▼
              ┌───────────────┐
              │ Tap "Blokir"  │
              └───────┬───────┘
                      │
                      ▼
        ┌─────────────────────────┐
        │ Accessibility Service   │
        │ sudah aktif?            │
        └───┬───────────────┬─────┘
            │               │
          TIDAK            YA
            │               │
            ▼               ▼
    ┌──────────────┐  ┌──────────────┐
    │ Buka Settings│  │ Tambah ke    │
    │ → Accessibility│  │ daftar block │
    └───────┬──────┘  └──────┬───────┘
            │                │
            │                │
            ▼                │
    ┌──────────────┐         │
    │ Aktifkan     │         │
    │ Service      │         │
    └───────┬──────┘         │
            │                │
            └────────┬────────┘
                     │
                     ▼
            ┌───────────────┐
            │ Aktifkan      │
            │ Toggle di App │
            └───────┬───────┘
                    │
                    ▼
            ┌───────────────┐
            │ Test Blocking │
            │ (Buka app)    │
            └───────┬───────┘
                    │
                    ▼
            ┌───────────────┐
            │   SUCCESS!    │
            │  App tertutup │
            └───────────────┘
```

---

**Diagram ini membantu memahami alur penggunaan aplikasi secara visual! 📊**

