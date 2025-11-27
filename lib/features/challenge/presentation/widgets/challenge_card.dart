import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/challenge.dart';
import '../providers/challenge_provider.dart';

/// Challenge Card Widget
/// Widget untuk menampilkan card challenge dengan informasi lengkap
/// Mengikuti konsep Single Responsibility Principle

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  const ChallengeCard({super.key, required this.challenge});

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

  Future<void> _start(BuildContext context) async {
    final provider = context.read<ChallengeProvider>();
    String? bookName;
    String? eventName;

    if (challenge.category == 'membaca_buku' || challenge.category == 'bersosialisasi') {
      final controller = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(challenge.category == 'membaca_buku' ? 'Nama Buku' : 'Nama Event'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: challenge.category == 'membaca_buku' ? 'Contoh: Atomic Habits' : 'Contoh: Meetup Flutter',
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
            ],
          );
        },
      );
      if (ok != true) return;
      if (challenge.category == 'membaca_buku') {
        bookName = controller.text.trim();
      } else {
        eventName = controller.text.trim();
      }
    }

    final ok = await provider.start(
      challengeId: challenge.id,
      bookName: bookName,
      eventName: eventName,
    );

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Gagal memulai challenge')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(context, challenge.category);
    final categoryIcon = _getCategoryIcon(challenge.category);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _start(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        categoryIcon,
                        color: categoryColor,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
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
                          if (challenge.pointsReward != null)
                            Text(
                              '${challenge.pointsReward}',
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
                const SizedBox(height: 16),
                Text(
                  challenge.challengeName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (challenge.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    challenge.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${challenge.durationDays} hari',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        challenge.category.replaceAll('_', ' '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Mulai',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


