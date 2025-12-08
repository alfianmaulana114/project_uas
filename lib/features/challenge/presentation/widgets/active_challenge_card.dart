import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../challenge/domain/entities/user_challenge.dart';
import '../../presentation/providers/challenge_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../reward/presentation/providers/reward_provider.dart';
import '../../../reward/presentation/widgets/achievement_unlock_dialog.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'social_media':
        return Icons.phone_android;
      case 'olahraga':
        return Icons.fitness_center;
      case 'bersosialisasi':
        return Icons.people;
      case 'membaca_buku':
        return Icons.menu_book;
      default:
        return Icons.flag;
    }
  }

  Color _getCategoryColor(BuildContext context, String category) {
    switch (category) {
      case 'social_media':
        return Colors.purple.shade400;
      case 'olahraga':
        return Colors.blue.shade400;
      case 'bersosialisasi':
        return Colors.green.shade400;
      case 'membaca_buku':
        return Colors.orange.shade400;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final challengeProvider = context.watch<ChallengeProvider>();
    final isLoading = challengeProvider.isLoading;
    // Gunakan sync version untuk immediate UI update
    // Provider akan update dari database di background saat load
    final hasCheckedToday = challengeProvider.hasCheckedInTodaySync(userChallenge.id);
    final totalDays = userChallenge.endDate == null
        ? userChallenge.currentDay
        : (userChallenge.endDate!.difference(userChallenge.startDate).inDays + 1).clamp(1, 3650);

    /// Hitung progress percentage
    /// Progress = currentDay / totalDays
    final percent = totalDays > 0
        ? (userChallenge.currentDay / totalDays).clamp(0.0, 1.0)
        : 0.0;

    final categoryColor = _getCategoryColor(context, userChallenge.category);
    final categoryIcon = _getCategoryIcon(userChallenge.category);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withOpacity(0.1),
            categoryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userChallenge.category.replaceAll('_', ' ').toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Challenge Aktif',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${userChallenge.pointsEarned}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
              ),
            ),
            const SizedBox(height: 16),
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Hari',
                    value: '${userChallenge.currentDay}/$totalDays',
                    color: categoryColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.check_circle,
                    label: 'Sukses',
                    value: '${userChallenge.successDays}',
                    color: categoryColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.percent,
                    label: 'Progress',
                    value: '${(percent * 100).toInt()}%',
                    color: categoryColor,
                  ),
                ),
              ],
            ),
            if (userChallenge.category == 'social_media') ...[
              const SizedBox(height: 20),
              SocialMediaChallengePanel(initialApps: _mockSocialApps),
            ] else if (userChallenge.bookName != null || userChallenge.eventName != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  if (userChallenge.bookName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            userChallenge.bookName!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (userChallenge.eventName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            userChallenge.eventName!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: Icon(hasCheckedToday ? Icons.check_circle : Icons.thumb_up_outlined),
                label: Text(hasCheckedToday ? 'Sudah Check-in Hari Ini' : 'Mulai Hari Ini'),
                style: FilledButton.styleFrom(
                  backgroundColor: categoryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: (isLoading || hasCheckedToday)
                    ? null
                    : () async {
                        // Show dialog untuk input waktu
                        final durationMinutes = await showDialog<int>(
                          context: context,
                          builder: (context) => const _DurationInputDialog(),
                        );
                        
                        if (durationMinutes == null) return;
                        
                        final p = context.read<ChallengeProvider>();
                        final res = await p.checkIn(
                          userChallengeId: userChallenge.id,
                          isSuccess: true,
                          durationMinutes: durationMinutes,
                        );
                        if (res == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(p.error ?? 'Gagal check-in')),
                            );
                          }
                          return;
                        }
                        // Pastikan state ter-update setelah check-in
                        // Provider sudah memanggil notifyListeners() di checkIn method
                        // Widget akan otomatis rebuild karena menggunakan context.watch
                        // Tidak perlu memanggil setState karena widget sudah menggunakan context.watch
                        // Update poin saja; streak mengikuti tanggal riil
                        context.read<AuthProvider>().applyStatsUpdate(
                              totalPoints: res.totalPoints,
                            );
                        
                        // Refresh Analytics untuk update data waktu realtime
                        final analyticsProvider = context.read<AnalyticsProvider>();
                        final auth = context.read<AuthProvider>();
                        final uid = auth.currentUser?.id;
                        if (uid != null && context.mounted) {
                          await analyticsProvider.load(uid);
                        }
                        
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
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Dialog untuk input durasi aktivitas dalam menit
class _DurationInputDialog extends StatefulWidget {
  const _DurationInputDialog();

  @override
  State<_DurationInputDialog> createState() => _DurationInputDialogState();
}

class _DurationInputDialogState extends State<_DurationInputDialog> {
  final _controller = TextEditingController();
  int _selectedMinutes = 15;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Berapa lama aktivitas?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Masukkan durasi aktivitas dalam menit'),
          const SizedBox(height: 16),
          // Quick select buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [15, 30, 45, 60, 90, 120].map((minutes) {
              final isSelected = _selectedMinutes == minutes;
              return ChoiceChip(
                label: Text('${minutes}m'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedMinutes = minutes;
                      _controller.text = minutes.toString();
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Durasi (menit)',
              hintText: 'Masukkan durasi',
              prefixIcon: Icon(Icons.timer_outlined),
            ),
            onChanged: (value) {
              final minutes = int.tryParse(value);
              if (minutes != null && minutes > 0) {
                setState(() => _selectedMinutes = minutes);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedMinutes),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}


