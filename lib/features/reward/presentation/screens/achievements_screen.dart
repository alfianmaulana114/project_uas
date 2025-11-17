import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/reward_provider.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/points_display.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RewardProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RewardProvider>();
    final ownedIds = provider.owned.map((e) => e.achievementId).toSet();
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PointsDisplay(),
            const SizedBox(height: 12),
            if (provider.isLoading) const LinearProgressIndicator(),
            if (provider.error != null)
              Text(provider.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: provider.achievements
                    .map((a) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AchievementBadge(
                                  achievement: a,
                                  earned: ownedIds.contains(a.id),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  a.description ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}