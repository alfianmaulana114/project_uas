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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.flag, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge.challengeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (challenge.description != null) ...[
                    const SizedBox(height: 4),
                    Text(challenge.description!, style: const TextStyle(color: Colors.grey)),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text('${challenge.durationDays} hari')),
                      if (challenge.pointsReward != null) Chip(label: Text('+${challenge.pointsReward} poin')),
                      Chip(label: Text(challenge.category.replaceAll('_', ' '))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () => _start(context),
              child: const Text('Mulai'),
            ),
          ],
        ),
      ),
    );
  }
}


