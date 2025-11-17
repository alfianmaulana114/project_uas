import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../presentation/providers/analytics_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/checkin_bar_chart.dart';







class ProgressComparisonChart extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int completedChallenges;

  const ProgressComparisonChart({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedChallenges,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = [currentStreak.toDouble(), longestStreak.toDouble(), completedChallenges.toDouble()];
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    double scale(double v) => maxVal <= 0 ? 0 : (v / maxVal);

    Widget bar(String label, IconData icon, double value) {
      return Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: scale(value),
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: Text(
              '${value.toInt()}',
              textAlign: TextAlign.right,
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        bar('Current Streak', Icons.local_fire_department, currentStreak.toDouble()),
        const SizedBox(height: 8),
        bar('Longest Streak', Icons.timeline, longestStreak.toDouble()),
        const SizedBox(height: 8),
        bar('Completed', Icons.flag, completedChallenges.toDouble()),
      ],
    );
  }
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _chartMode = 'weekly';

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
                    const SizedBox(height: 12),
                    Text('Progress Chart', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ProgressComparisonChart(
                      currentStreak: stats.currentStreak,
                      longestStreak: stats.longestStreak,
                      completedChallenges: stats.completedChallenges,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Mingguan'),
                        selected: _chartMode == 'weekly',
                        onSelected: (_) => setState(() => _chartMode = 'weekly'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Bulanan'),
                        selected: _chartMode == 'monthly',
                        onSelected: (_) => setState(() => _chartMode = 'monthly'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_chartMode == 'weekly') ...[
                    Text('Check-in 7 Hari Terakhir', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (weekly.isNotEmpty)
                      CheckinBarChart(data: weekly)
                    else
                      const SizedBox(
                        height: 200,
                        child: Center(child: Text('Belum ada data check-in minggu ini')),
                      ),
                  ] else ...[
                    const SizedBox(height: 8),
                    const SizedBox(
                      height: 200,
                      child: Center(child: Text('Grafik bulanan akan hadir segera')), 
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}