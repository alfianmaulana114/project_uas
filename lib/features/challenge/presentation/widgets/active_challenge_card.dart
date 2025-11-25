import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../challenge/domain/entities/user_challenge.dart';
import '../../presentation/providers/challenge_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../reward/presentation/providers/reward_provider.dart';
import '../../../reward/presentation/widgets/achievement_unlock_dialog.dart';
import 'social_media_challenge_panel.dart';

/// Active Challenge Card Widget
/// Widget untuk menampilkan card challenge yang sedang aktif
/// Mengikuti konsep Single Responsibility Principle

class ActiveChallengeCard extends StatelessWidget {
  final UserChallenge userChallenge;
  const ActiveChallengeCard({super.key, required this.userChallenge});

  static const List<SocialAppUsage> _mockSocialApps = [
    SocialAppUsage(name: 'TikTok', minutesPerDay: 60, icon: Icons.music_note, isBlocked: true),
    SocialAppUsage(name: 'Instagram', minutesPerDay: 45, icon: Icons.photo_camera, isBlocked: true),
    SocialAppUsage(name: 'Facebook', minutesPerDay: 30, icon: Icons.facebook, isBlocked: true),
    SocialAppUsage(name: 'Snapchat', minutesPerDay: 25, icon: Icons.snapchat, isBlocked: true),
    SocialAppUsage(name: 'YouTube', minutesPerDay: 90, icon: Icons.play_circle, isBlocked: false),
    SocialAppUsage(name: 'Twitter/X', minutesPerDay: 15, icon: Icons.alternate_email, isBlocked: false),
  ];

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ChallengeProvider>().isLoading;
    final hasCheckedToday = context.watch<ChallengeProvider>().hasCheckedInToday(userChallenge.id);
    final totalDays = userChallenge.endDate == null
        ? userChallenge.currentDay
        : (userChallenge.endDate!.difference(userChallenge.startDate).inDays + 1).clamp(1, 3650);

    /// Hitung progress percentage
    /// Progress = currentDay / totalDays
    final percent = totalDays > 0
        ? (userChallenge.currentDay / totalDays).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline),
                const SizedBox(width: 8),
                Text(userChallenge.category.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            // Progress Bar - Soft Blue
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 12,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue.shade200, // Soft blue
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Label progress dengan icon - Font lebih besar
            Row(
              children: [
                const Text(
                  '📅',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  'Hari ${userChallenge.currentDay}/$totalDays',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                ),
                const SizedBox(width: 16),
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
            if (userChallenge.category == 'social_media') ...[
              const SizedBox(height: 12),
              SocialMediaChallengePanel(initialApps: _mockSocialApps),
            ] else if (userChallenge.bookName != null || userChallenge.eventName != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (userChallenge.bookName != null) Chip(label: Text('Buku: ${userChallenge.bookName}')),
                  if (userChallenge.eventName != null) Chip(label: Text('Event: ${userChallenge.eventName}')),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.thumb_up_outlined),
                    label: const Text('Mark Success'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.shade700, // Strong blue
                      foregroundColor: Colors.white,
                      elevation: 2,
                      disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: (isLoading || hasCheckedToday)
                        ? null
                        : () async {
                            final p = context.read<ChallengeProvider>();
                            final res = await p.checkIn(
                                userChallengeId: userChallenge.id, isSuccess: true);
                            if (res == null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(p.error ?? 'Gagal check-in')),
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
                            // Check and award achievements after a check-in or completion
                            final rewards = await context
                                .read<RewardProvider>()
                                .checkAfterEvent(
                                    trigger: res.challengeCompleted ? 'challenge_completed' : 'checkin');
                            if (context.mounted && rewards.isNotEmpty) {
                              await showDialog(
                                context: context,
                                builder: (_) => AchievementUnlockDialog(achievements: rewards),
                              );
                            }
                            if (context.mounted) {
                              if (res.alreadyCheckedInToday) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sudah check-in hari ini')),
                                );
                              } else if (res.challengeCompleted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Challenge selesai! +${res.pointsAwarded} poin')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Berhasil untuk hari ini. Lanjutkan lagi besok.')),
                                );
                              }
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


