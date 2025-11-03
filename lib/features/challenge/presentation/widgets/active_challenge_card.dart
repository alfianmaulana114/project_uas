import 'package:flutter/material.dart';
import '../../domain/entities/user_challenge.dart';
import 'progress_bar.dart';

/// Active Challenge Card Widget
/// Widget untuk menampilkan card challenge yang sedang aktif
/// Mengikuti konsep Single Responsibility Principle

class ActiveChallengeCard extends StatelessWidget {
  final UserChallenge userChallenge;
  const ActiveChallengeCard({super.key, required this.userChallenge});

  @override
  Widget build(BuildContext context) {
    /// Hitung total hari challenge
    /// Jika endDate null, gunakan currentDay sebagai estimasi
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
            ProgressBar(
              value: percent,
              showLabel: true,
            ),
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
          ],
        ),
      ),
    );
  }
}


