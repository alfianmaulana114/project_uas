import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../presentation/providers/analytics_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/checkin_bar_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final analytics = context.read<AnalyticsProvider>();
      final uid = auth.currentUser?.id ?? '';
      if (uid.isNotEmpty) {
        analytics.load(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final stats = provider.stats;
    final weekly = provider.weekly;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                final auth = context.read<AuthProvider>();
                final uid = auth.currentUser?.id ?? '';
                if (uid.isNotEmpty) await provider.load(uid);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (stats != null) ...[
                    StatsCard(title: 'Total Points', value: '${stats.totalPoints}', icon: Icons.star),
                    StatsCard(title: 'Current Streak', value: '${stats.currentStreak}', icon: Icons.local_fire_department),
                    StatsCard(title: 'Longest Streak', value: '${stats.longestStreak}', icon: Icons.timeline),
                    StatsCard(title: 'Completed Challenges', value: '${stats.completedChallenges}', icon: Icons.flag),
                    StatsCard(title: 'Activities Completed', value: '${stats.activitiesCompleted}', icon: Icons.check_circle),
                    StatsCard(title: 'Badges Earned', value: '${stats.badgesEarned}', icon: Icons.emoji_events),
                    const SizedBox(height: 12),
                  ],
                  Text('Check-in 7 Hari Terakhir', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (weekly.isNotEmpty)
                    CheckinBarChart(data: weekly)
                  else
                    const SizedBox(
                      height: 200,
                      child: Center(child: Text('Belum ada data check-in minggu ini')),
                    ),
                ],
              ),
            ),
    );
  }
}