import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../challenge/presentation/screens/challenge_list_screen.dart';
import '../../../challenge/presentation/providers/challenge_provider.dart';
import '../../../reward/presentation/screens/leaderboard_screen.dart';
import '../widgets/motivational_empty_state.dart';
import '../widgets/progress_summary_widget.dart';
import '../widgets/streak_celebration_widget.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../analytics/presentation/widgets/stats_card.dart';
import '../../../analytics/presentation/widgets/checkin_bar_chart.dart';

/// Dashboard Screen
/// Screen utama aplikasi dengan navigation bar
/// Mengikuti konsep Single Responsibility Principle
class DashboardScreen extends StatefulWidget {
  /// Constructor untuk DashboardScreen 
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Index tab yang sedang aktif
  int _index = 0;

  void _switchToChallengeTab() {
    setState(() {
      _index = 1; // Switch to Challenge tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeTab(onNavigateToChallenges: _switchToChallengeTab),
      const ChallengeListScreen(),
      const AnalyticsScreen(),
      const LeaderboardScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Challenge'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.leaderboard_outlined), selectedIcon: Icon(Icons.leaderboard), label: 'Ranking'),
        ],
      ),
    );
  }
}

/// Home Tab
/// Menampilkan dashboard home dengan active challenges
class _HomeTab extends StatefulWidget {
  final VoidCallback onNavigateToChallenges;
  
  const _HomeTab({required this.onNavigateToChallenges});
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  late final String _quote;
  int? _previousStreak;
  bool _showStreakCelebration = false;
  
  static const List<String> _quotes = [
    'Kurangi scroll, tambahkan langkah menuju tujuanmu.',
    'Kamu Hebat! Kendalikan waktumu, bukan layar.',
    'Satu hari tanpa scroll berlebihan adalah satu langkah maju.',
    'Fokus pada hal yang membuatmu berkembang, bukan yang mengalihkan.',
    'Detox sosmed dimulai dari keputusan kecil hari ini.',
  ];

  @override
  void initState() {
    super.initState();
    _quote = _quotes[DateTime.now().day % _quotes.length];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().load();
      final auth = context.read<AuthProvider>();
      final uid = auth.currentUser?.id ?? '';
      if (uid.isNotEmpty) {
        context.read<AnalyticsProvider>().load(uid);
      }
      // Initialize previous streak
      _previousStreak = auth.currentUser?.currentStreak;
    });
  }

  void _checkStreakIncrease(int currentStreak) {
    // Only trigger animation if:
    // 1. Previous streak is not null (already initialized)
    // 2. Current streak is greater than previous
    // 3. Not already showing celebration
    if (_previousStreak != null && 
        currentStreak > _previousStreak! && 
        !_showStreakCelebration) {
      // Streak bertambah!
      setState(() {
        _showStreakCelebration = true;
      });
    }
    // Update previous streak
    _previousStreak = currentStreak;
  }

  @override
  Widget build(BuildContext context) {
    // Monitor streak changes
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final currentStreak = authProvider.currentUser?.currentStreak ?? 0;
        
        // Check for streak increase after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkStreakIncrease(currentStreak);
          }
        });
        
        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            const SizedBox(height: 8),
            // Level 3: Sekunder (motivasi) - paling terang
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Motivasi & Pesan Positif',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _quote,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            MotivationalEmptyState(onNavigateToChallenges: widget.onNavigateToChallenges),
            const SizedBox(height: 16),
            ProgressSummaryWidget(onNavigateToChallenges: widget.onNavigateToChallenges),
            const SizedBox(height: 16),
            Text(
              'Visualisasi Data & Statistik',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Consumer<AnalyticsProvider>(
              builder: (context, analytics, _) {
                final stats = analytics.stats;
                final weekly = analytics.weekly;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stats != null) ...[
                      StatsCard(title: 'Total Poin', value: '${stats.totalPoints}', icon: Icons.star),
                      StatsCard(title: 'Challenge Selesai', value: '${stats.completedChallenges}', icon: Icons.flag),
                      StatsCard(title: 'Streak Terpanjang', value: '${stats.longestStreak}', icon: Icons.timeline),
                      const SizedBox(height: 12),
                    ],
                    Text('Check-in 7 Hari Terakhir', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    if (weekly.isNotEmpty)
                      CheckinBarChart(data: weekly)
                    else
                      const SizedBox(
                        height: 160,
                        child: Center(child: Text('Belum ada data minggu ini')),
                      ),
                  ],
                );
              },
            ),
              ],
            ),
          ),
          // Streak celebration animation overlay
          if (_showStreakCelebration)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: StreakCelebrationWidget(
                  onAnimationComplete: () {
                    setState(() {
                      _showStreakCelebration = false;
                    });
                  },
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


