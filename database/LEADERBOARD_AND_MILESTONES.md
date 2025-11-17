# Fitur Leaderboard & Milestone Achievements

## 📊 Leaderboard

Fitur leaderboard menampilkan ranking pengguna berdasarkan berbagai metrik:
- **Poin** (default) - Total poin yang dikumpulkan
- **Streak** - Streak hari saat ini
- **Challenge** - Jumlah challenge yang diselesaikan
- **Check-in** - Total check-in yang berhasil

### Cara Menggunakan

1. Leaderboard dapat diakses dari tab "Ranking" di navigation bar
2. Gunakan menu di AppBar untuk mengubah sorting (Poin, Streak, Challenge, Check-in)
3. Pull to refresh untuk memperbarui data
4. User saat ini akan ditandai dengan highlight khusus

### Implementasi

- **Entity**: `LeaderboardEntry` - Menyimpan data ranking user
- **Repository**: `RewardRepository.getLeaderboard()` - Mengambil data leaderboard
- **UseCase**: `GetLeaderboardUsecase` - Business logic untuk leaderboard
- **Provider**: `RewardProvider.loadLeaderboard()` - State management
- **Screen**: `LeaderboardScreen` - UI untuk menampilkan leaderboard

## 🏆 Milestone Achievements

Sistem achievement otomatis memberikan badge dan poin ketika user mencapai milestone tertentu.

### Milestone yang Tersedia

#### Streak Milestones
- **7 Hari Streak** - 50 poin 🔥
- **14 Hari Streak** - 100 poin 🔥🔥
- **30 Hari Streak** - 250 poin 🔥🔥🔥
- **60 Hari Streak** - 500 poin 🔥🔥🔥🔥
- **100 Hari Streak** - 1000 poin 🔥🔥🔥🔥🔥

#### Challenge Completion Milestones
- **Challenge Pertama** - 25 poin 🎯
- **5 Challenge** - 100 poin 🎯🎯
- **10 Challenge** - 200 poin 🎯🎯🎯
- **30 Challenge** - 500 poin 🎯🎯🎯🎯
- **50 Challenge** - 1000 poin 🎯🎯🎯🎯🎯

#### Check-in Milestones
- **Check-in Pertama** - 10 poin ✅
- **10 Hari Check-in** - 50 poin ✅✅
- **30 Hari Check-in** - 150 poin ✅✅✅
- **60 Hari Check-in** - 300 poin ✅✅✅✅
- **100 Hari Check-in** - 500 poin ✅✅✅✅✅

### Setup Database

Jalankan file SQL berikut di Supabase SQL Editor:
```sql
database/setup_milestone_achievements.sql
```

### Cara Kerja

1. Sistem otomatis mengecek achievement setelah:
   - Check-in berhasil
   - Challenge selesai
   - Streak bertambah

2. Jika user memenuhi requirement achievement:
   - Achievement otomatis diberikan
   - Poin ditambahkan ke total poin user
   - Dialog muncul untuk memberitahu user

3. Achievement yang sudah didapat tidak akan diberikan lagi

### Implementasi

- **Entity**: `Achievement` - Definisi achievement
- **UseCase**: `CheckAchievementsUsecase` - Mengevaluasi dan memberikan achievement
- **Provider**: `RewardProvider.checkAfterEvent()` - Dipanggil setelah event tertentu
- **Screen**: `AchievementsScreen` - Menampilkan semua achievement

## 🔄 Integrasi

### Leaderboard
Leaderboard terintegrasi dengan:
- Navigation bar (tab ke-4)
- RewardProvider untuk state management
- AuthProvider untuk identifikasi user saat ini

### Milestone Achievements
Milestone achievements terintegrasi dengan:
- ChallengeProvider - Dipanggil setelah check-in atau challenge selesai
- RewardProvider - Mengevaluasi dan memberikan achievement
- AuthProvider - Update poin user

## 📝 Catatan

- Leaderboard diurutkan berdasarkan metrik yang dipilih (default: poin)
- Achievement hanya diberikan sekali per user
- Poin dari achievement langsung ditambahkan ke total poin user
- Leaderboard menampilkan maksimal 100 user (dapat diubah di `loadLeaderboard(limit: ...)`)

