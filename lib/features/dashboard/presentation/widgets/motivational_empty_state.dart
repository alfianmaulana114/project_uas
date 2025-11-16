import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

/// Widget untuk menampilkan pesan motivasional ketika user belum memiliki poin atau streak
/// Mengikuti konsep Empty State Pattern untuk meningkatkan user engagement
class MotivationalEmptyState extends StatelessWidget {
  final VoidCallback onNavigateToChallenges;
  
  const MotivationalEmptyState({
    super.key,
    required this.onNavigateToChallenges,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        final totalPoints = user?.totalPoints ?? 0;
        final currentStreak = user?.currentStreak ?? 0;

        // Tampilkan widget ini hanya jika poin = 0 dan streak = 0
        if (totalPoints > 0 || currentStreak > 0) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon motivasional
              Icon(
                Icons.rocket_launch_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              
              // Teks motivasional
              Text(
                'Belum ada poin. Mulai challenge pertama untuk mengurangi waktu sosmedmu!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Tombol CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onNavigateToChallenges,
                  icon: const Icon(Icons.flag_rounded),
                  label: const Text('Mulai Challenge'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

