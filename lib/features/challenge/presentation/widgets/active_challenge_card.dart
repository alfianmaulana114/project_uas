import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../challenge/domain/entities/user_challenge.dart';
import '../../presentation/providers/challenge_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import 'progress_bar.dart';
import '../../../reward/presentation/providers/reward_provider.dart';
import '../../../reward/presentation/widgets/achievement_unlock_dialog.dart';

class ActiveChallengeCard extends StatelessWidget {
  final UserChallenge userChallenge;
  const ActiveChallengeCard({super.key, required this.userChallenge});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ChallengeProvider>().isLoading;
    final hasCheckedToday = context.watch<ChallengeProvider>().hasCheckedInToday(userChallenge.id);
    final totalDays = userChallenge.endDate == null
        ? userChallenge.currentDay
        : (userChallenge.endDate!.difference(userChallenge.startDate).inDays + 1).clamp(1, 3650);
    final percent = (userChallenge.currentDay / totalDays).clamp(0.0, 1.0);

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
            ProgressBar(value: percent),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('Hari ${userChallenge.currentDay}/$totalDays')),
                Chip(label: Text('Sukses ${userChallenge.successDays}')),
                if (userChallenge.bookName != null) Chip(label: Text('Buku: ${userChallenge.bookName}')),
                if (userChallenge.eventName != null) Chip(label: Text('Event: ${userChallenge.eventName}')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.thumb_up_outlined),
                    label: const Text('Mark Success'),
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


