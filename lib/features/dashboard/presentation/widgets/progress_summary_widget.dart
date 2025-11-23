import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../challenge/presentation/providers/challenge_provider.dart';
import '../../../challenge/domain/entities/user_challenge.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../reward/presentation/providers/reward_provider.dart';
import '../../../reward/presentation/widgets/achievement_unlock_dialog.dart';

/// Widget untuk menampilkan ringkasan progress yang lebih visual
/// Menampilkan streak, poin, dan challenge aktif dengan progress bar
class ProgressSummaryWidget extends StatelessWidget {
  final VoidCallback onNavigateToChallenges;
  
  const ProgressSummaryWidget({
    super.key,
    required this.onNavigateToChallenges,
  });

  String _getStreakMessage(int streak) {
    if (streak == 0) return 'Mulai streak pertamamu!';
    if (streak < 3) return 'Bagus! Pertahankan terus!';
    if (streak < 7) return 'Kamu hebat! Lanjutkan!';
    if (streak < 14) return 'Sangat mengesankan!';
    if (streak < 30) return 'Luar biasa! Kamu konsisten!';
    return 'Wow! Kamu luar biasa!';
  }

  int _calculateTotalDays(UserChallenge userChallenge) {
    if (userChallenge.endDate != null) {
      return (userChallenge.endDate!.difference(userChallenge.startDate).inDays + 1).clamp(1, 3650);
    }
    // Jika tidak ada endDate, gunakan currentDay sebagai estimasi
    return userChallenge.currentDay;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ChallengeProvider>(
      builder: (context, authProvider, challengeProvider, _) {
        final user = authProvider.currentUser;
        final currentStreak = user?.currentStreak ?? 0;
        final totalPoints = user?.totalPoints ?? 0;
        final activeChallenges = challengeProvider.activeChallenges;
        final isLoading = challengeProvider.isLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Streak Saat Ini - Level 2: Informasi (medium gray)
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      '🔥',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Streak Saat Ini',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentStreak hari',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStreakMessage(currentStreak),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ⭐ Total Poin - Level 2: Informasi (medium gray)
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      '⭐',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Poin',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalPoints poin',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🎯 Challenge Aktif - Level 1: Card Utama (strong/light purple)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '🎯',
                          style: TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Challenge Aktif',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (activeChallenges.isEmpty)
                      // Tidak ada challenge aktif
                      Column(
                        children: [
                          Text(
                            'Tidak ada challenge aktif',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: onNavigateToChallenges,
                              icon: const Icon(Icons.flag_rounded),
                              label: const Text('Mulai Challenge Baru'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // Ada challenge aktif - tampilkan progress
                      ...activeChallenges.asMap().entries.map((entry) {
                        final index = entry.key;
                        final userChallenge = entry.value;
                        final totalDays = _calculateTotalDays(userChallenge);
                        final currentDay = userChallenge.currentDay;
                        final progress = (currentDay / totalDays).clamp(0.0, 1.0);
                        final hasCheckedToday = challengeProvider.hasCheckedInToday(userChallenge.id);
                        final isLast = index == activeChallenges.length - 1;

                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama/Kategori Challenge
                              Row(
                                children: [
                                  Icon(
                                    Icons.flag_rounded,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      userChallenge.category.replaceAll('_', ' ').toUpperCase(),
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              if (userChallenge.bookName != null || userChallenge.eventName != null) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    if (userChallenge.bookName != null)
                                      Chip(
                                        label: Text('Buku: ${userChallenge.bookName}'),
                                        labelStyle: Theme.of(context).textTheme.bodySmall,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      ),
                                    if (userChallenge.eventName != null)
                                      Chip(
                                        label: Text('Event: ${userChallenge.eventName}'),
                                        labelStyle: Theme.of(context).textTheme.bodySmall,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              // Progress Bar - Soft Blue
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 12,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue.shade200, // Soft blue
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Label progress dengan icon - Font lebih besar
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '📅',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Hari $currentDay/$totalDays',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '✔',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${userChallenge.successDays} sukses',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Tombol Mark Success dengan state indicator
                              Builder(
                                builder: (context) {
                                  // State: sudah check-in hari ini (hijau)
                                  if (hasCheckedToday) {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('✔ Sudah Berhasil Hari Ini'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.green.shade100,
                                          foregroundColor: Colors.green.shade800,
                                          disabledBackgroundColor: Colors.green.shade100,
                                          disabledForegroundColor: Colors.green.shade800,
                                        ),
                                        onPressed: null, // Disabled karena sudah check-in
                                      ),
                                    );
                                  }
                                  
                                  // State: loading
                                  if (isLoading) {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        icon: const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        label: const Text('Memproses...'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                                          disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        onPressed: null, // Disabled saat loading
                                      ),
                                    );
                                  }
                                  
                                  // State: normal (bisa diklik) - Strong Blue
                                  return SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      icon: const Icon(Icons.check_circle_outline),
                                      label: const Text('Mark Success'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700, // Strong blue
                                        foregroundColor: Colors.white,
                                        elevation: 2,
                                      ),
                                      onPressed: () async {
                                          final p = context.read<ChallengeProvider>();
                                          final res = await p.checkIn(
                                            userChallengeId: userChallenge.id,
                                            isSuccess: true,
                                          );
                                          
                                          if (res == null) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(p.error ?? 'Gagal check-in'),
                                                  backgroundColor: Theme.of(context).colorScheme.error,
                                                ),
                                              );
                                            }
                                            return;
                                          }
                                          
                                          // Update user stats in AuthProvider
                                          context.read<AuthProvider>().applyStatsUpdate(
                                                currentStreak: res.currentStreak,
                                                longestStreak: res.longestStreak,
                                                totalPoints: res.totalPoints,
                                              );
                                          
                                          // Check and award achievements
                                          final rewards = await context
                                              .read<RewardProvider>()
                                              .checkAfterEvent(
                                                trigger: res.challengeCompleted
                                                    ? 'challenge_completed'
                                                    : 'checkin',
                                              );
                                          
                                          if (context.mounted && rewards.isNotEmpty) {
                                            await showDialog(
                                              context: context,
                                              builder: (_) => AchievementUnlockDialog(
                                                achievements: rewards,
                                              ),
                                            );
                                          }
                                          
                                          if (context.mounted) {
                                            if (res.alreadyCheckedInToday) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Sudah check-in hari ini'),
                                                ),
                                              );
                                            } else if (res.challengeCompleted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Challenge selesai! +${res.pointsAwarded} poin',
                                                  ),
                                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    'Berhasil untuk hari ini. Lanjutkan lagi besok.',
                                                  ),
                                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

