import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../presentation/providers/analytics_provider.dart';

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

  Color _usageColor(int minutes) {
    if (minutes >= 100) return Colors.redAccent;
    if (minutes >= 70) return Colors.orangeAccent;
    if (minutes >= 50) return Colors.amber;
    return Colors.green;
  }

  String _weekdayLabel(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Ming'];
    return days[(date.weekday - 1) % days.length];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final stats = provider.stats;
    final weekly = [...provider.weekly]..sort((a, b) => a.date.compareTo(b.date));

    final totalMinutes = weekly.fold<int>(0, (sum, day) => sum + day.successCount);
    final averageMinutes = weekly.isEmpty ? 0 : (totalMinutes / weekly.length).round();
    final totalSessions =
        weekly.fold<int>(0, (sum, day) => sum + day.successCount + day.failedCount);
    final improvementPercent = totalSessions == 0
        ? 0
        : ((weekly.fold<int>(0, (sum, day) => sum + day.successCount) / totalSessions) * 100).round();
    final streakDays = stats?.currentStreak ?? 0;
    final maxMinutes = weekly.isEmpty
        ? 0
        : weekly.map((e) => e.successCount).reduce((value, element) => value > element ? value : element);

    return Scaffold(
      appBar: AppBar(title: const Text('Social Detox')),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7A18), Color(0xFFFFB347)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  Row(
                    children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Social Detox',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kontrol sosial media Anda',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_fire_department, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text('$streakDays hari',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progress Minggu Ini',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {},
                              icon: const Icon(Icons.calendar_today, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _AnalyticsStatCard(
                            label: 'Total Waktu',
                            value: '${totalMinutes}m',
                            color: const Color(0xFFFF8A3C),
                            icon: Icons.timelapse,
                            width: cardWidth,
                          ),
                          _AnalyticsStatCard(
                            label: 'Rata-rata',
                            value: '${averageMinutes}m',
                            color: const Color(0xFFFFA94F),
                            icon: Icons.show_chart,
                            width: cardWidth,
                          ),
                          _AnalyticsStatCard(
                            label: 'Perbaikan',
                            value: '$improvementPercent%',
                            color: const Color(0xFF23A094),
                            icon: Icons.trending_down,
                            width: cardWidth,
                          ),
                          _AnalyticsStatCard(
                            label: 'Streak',
                            value: '$streakDays hari',
                            color: const Color(0xFFFF7A18),
                            icon: Icons.local_fire_department,
                            width: cardWidth,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ringkasan Harian', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 16),
                          if (weekly.isEmpty)
                            const SizedBox(
                              height: 160,
                              child: Center(child: Text('Belum ada data minggu ini')),
                            )
                          else
                            ...weekly.map((day) {
                              final minutes = day.successCount;
                              final barColor = _usageColor(minutes);
                              final progress = maxMinutes == 0 ? 0.0 : minutes / maxMinutes;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      child: Text(
                                        _weekdayLabel(day.date),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          minHeight: 14,
                                          value: progress,
                                          backgroundColor:
                                              Theme.of(context).colorScheme.surfaceVariant,
                                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        '${minutes}m',
                                        textAlign: TextAlign.right,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TrendsCard(
                    improvementPercent: improvementPercent,
                    bestDayText: weekly.isEmpty
                        ? 'Belum ada data'
                        : 'Paling produktif ${_weekdayLabel(weekly.reduce(
                              (a, b) => a.successCount <= b.successCount ? a : b,
                            ).date)}',
                    savedTimeHours: (totalMinutes / 60 * 0.75).toStringAsFixed(1),
                  ),
                  const SizedBox(height: 16),
                  _MonthlyComparisonCard(
                    weeklyTotals: weekly.isEmpty
                        ? const []
                        : [
                            (totalMinutes * 0.4).round(),
                            (totalMinutes * 0.32).round(),
                            (totalMinutes * 0.28).round(),
                          ],
                  ),
                  const SizedBox(height: 16),
                  _InsightsCard(
                    insights: [
                      'Paling produktif pada ${weekly.isNotEmpty ? _weekdayLabel(weekly.last.date) : 'akhir pekan'}',
                      'Penggunaan tertinggi terjadi pada ${weekly.isNotEmpty ? _weekdayLabel(weekly.first.date) : '---'} pagi',
                      'Pertahankan streak ${streakDays} hari kamu! 🔥',
                      'Coba target baru 60m/hari minggu depan',
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _TrendsCard extends StatelessWidget {
  final int improvementPercent;
  final String bestDayText;
  final String savedTimeHours;

  const _TrendsCard({
    required this.improvementPercent,
    required this.bestDayText,
    required this.savedTimeHours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A3C), Color(0xFFFFB347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white),
              SizedBox(width: 8),
              Text('Tren Positif', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _TrendTile(
            icon: Icons.insights,
            title: 'Penggunaan Menurun',
            subtitle: 'Berhasil kurangi $improvementPercent% minggu ini!',
          ),
          _TrendTile(
            icon: Icons.flag_circle,
            title: 'Target Tercapai',
            subtitle: '5 dari 7 hari di bawah target',
          ),
          _TrendTile(
            icon: Icons.timer_off,
            title: 'Waktu Tersimpan',
            subtitle: 'Hemat $savedTimeHours jam vs minggu lalu',
          ),
          _TrendTile(
            icon: Icons.emoji_events_outlined,
            title: 'Hari Terbaik',
            subtitle: bestDayText,
          ),
        ],
      ),
    );
  }
}

class _TrendTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrendTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFFF7A18),
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyComparisonCard extends StatelessWidget {
  final List<int> weeklyTotals;

  const _MonthlyComparisonCard({required this.weeklyTotals});

  @override
  Widget build(BuildContext context) {
    final reduction = weeklyTotals.isEmpty
        ? 0
        : weeklyTotals.first - weeklyTotals.last;
    final reductionPercent = weeklyTotals.isEmpty || weeklyTotals.first == 0
        ? 0
        : ((reduction / weeklyTotals.first) * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A18), Color(0xFFFFC77B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.white),
              SizedBox(width: 8),
              Text('Perbandingan Bulanan',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: List.generate(weeklyTotals.length, (index) {
              final value = weeklyTotals[index];
              return Container(
                width: 90,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('Minggu ${index + 1}', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text('${value}m',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Total Pengurangan', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  '${reduction >= 0 ? '-' : '+'}${reduction.abs()} menit ($reductionPercent%)',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  final List<String> insights;

  const _InsightsCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFFFF7A18)),
              SizedBox(width: 8),
              Text('Insight', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 18)),
                    Expanded(child: Text(text)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _AnalyticsStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final double width;

  const _AnalyticsStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4F0),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
                ],
              ),
            ),
    );
  }
}