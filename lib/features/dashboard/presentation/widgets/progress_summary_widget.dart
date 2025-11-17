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
            // 🔥 Streak Saat Ini
            Card(
              color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
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

            // ⭐ Total Poin
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
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

            // 🎯 Challenge Aktif
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
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
                              // Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 12,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Hari ke-X dari total
                              Text(
                                'Hari $currentDay dari $totalDays',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Tombol Mark Success
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text('Mark Success'),
                                  onPressed: (isLoading || hasCheckedToday)
                                      ? null
                                      : () async {
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
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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

