import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../challenge/presentation/screens/challenge_list_screen.dart';
import '../../../challenge/presentation/providers/challenge_provider.dart';
import '../../../challenge/domain/entities/challenge.dart';
import '../../../challenge/domain/entities/user_challenge.dart';
import '../../../target/presentation/screens/target_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/streak_celebration_widget.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../analytics/domain/entities/daily_checkin_stat.dart';
import '../../../analytics/presentation/widgets/checkin_bar_chart.dart';
import '../../../journal/presentation/screens/journal_list_screen.dart';

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeTab(onNavigateToChallenges: _switchToChallengeTab),
      const ChallengeListScreen(),
      const TargetScreen(),
      const AnalyticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Challenge'),
          NavigationDestination(icon: Icon(Icons.my_location_outlined), selectedIcon: Icon(Icons.my_location), label: 'Target'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
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
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  
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
    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });
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

  String _displayName(AuthProvider auth) {
    final user = auth.currentUser;
    if (user == null) return 'Teman SosialBreak';
    if ((user.fullName ?? '').trim().isNotEmpty) return user.fullName!.trim();
    if ((user.username ?? '').trim().isNotEmpty) return user.username!.trim();
    return user.email;
  }

  String _weekdayLabel(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Ming'];
    return days[(date.weekday - 1) % days.length];
  }

  Future<void> _refreshData() async {
    final challengeProvider = context.read<ChallengeProvider>();
    final analyticsProvider = context.read<AnalyticsProvider>();
    final auth = context.read<AuthProvider>();
    final uid = auth.currentUser?.id ?? '';
    await Future.wait([
      challengeProvider.load(category: challengeProvider.selectedCategory),
      if (uid.isNotEmpty) analyticsProvider.load(uid),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Monitor streak changes
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final currentStreak = authProvider.currentUser?.currentStreak ?? 0;
        final analytics = context.watch<AnalyticsProvider>();
        final challengeProvider = context.watch<ChallengeProvider>();
        final stats = analytics.stats;
        final weekly = [...analytics.weekly]..sort((a, b) => a.date.compareTo(b.date));
        final totalMinutes = weekly.fold<int>(0, (sum, day) => sum + day.successCount);
        final averageMinutes = weekly.isEmpty ? 0 : (totalMinutes / weekly.length).round();
        final recommendedTarget =
            weekly.isEmpty ? 60 : (averageMinutes * 0.8).clamp(30, 180).round();
        final bestDay = weekly.isEmpty
            ? 'Belum ada data'
            : _weekdayLabel(
                weekly.reduce((a, b) => a.successCount <= b.successCount ? a : b).date,
              );
        final activeChallenge = challengeProvider.activeChallenges.isNotEmpty
            ? challengeProvider.activeChallenges.first
            : null;
        Challenge? challengeDetail;
        if (activeChallenge != null) {
          for (final c in challengeProvider.challenges) {
            if (c.id == activeChallenge.challengeId) {
              challengeDetail = c;
              break;
            }
          }
        }
        
        // Check for streak increase after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkStreakIncrease(currentStreak);
          }
        });
        
        return Scaffold(
          appBar: AppBar(title: const Text('Social Detox')),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    Transform.translate(
                      offset: Offset(0, -_scrollOffset * 0.2),
                      child: Opacity(
                        opacity: (1 - (_scrollOffset / 200).clamp(0.0, 1.0)),
                        child: _HomeHeader(
                          name: _displayName(authProvider),
                          streak: currentStreak,
                          quote: _quote,
                          recommendedTarget: recommendedTarget,
                          bestDay: bestDay,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Transform.translate(
                      offset: Offset(0, -_scrollOffset * 0.15),
                      child: _QuickActionsGrid(actions: [
                        _QuickActionData(
                          title: 'Mulai Challenge',
                          subtitle: 'Cari tantangan baru',
                          icon: Icons.flag_outlined,
                          color: const Color(0xFFFF7A18),
                          onTap: widget.onNavigateToChallenges,
                        ),
                        _QuickActionData(
                          title: 'Atur Target',
                          subtitle: 'Sesuaikan limit harian',
                          icon: Icons.my_location_outlined,
                          color: const Color(0xFFFF9E42),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TargetScreen()),
                            );
                          },
                        ),
                        _QuickActionData(
                          title: 'Lihat Progress',
                          subtitle: 'Insight mingguan',
                          icon: Icons.insights_outlined,
                          color: const Color(0xFFFFC77B),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                            );
                          },
                        ),
                        _QuickActionData(
                          title: 'Catat Mood',
                          subtitle: 'Refleksi harian',
                          icon: Icons.edit_note_outlined,
                          color: const Color(0xFF374151),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const JournalListScreen()),
                            );
                          },
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Transform.translate(
                      offset: Offset(0, -_scrollOffset * 0.1),
                      child: _ActiveChallengeHighlight(
                        userChallenge: activeChallenge,
                        challengeDetail: challengeDetail,
                        onSeeAll: widget.onNavigateToChallenges,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Transform.translate(
                      offset: Offset(0, -_scrollOffset * 0.05),
                      child: _HomeAnalyticsPreview(
                        totalPoints: stats?.totalPoints ?? 0,
                        completedChallenges: stats?.completedChallenges ?? 0,
                        longestStreak: stats?.longestStreak ?? 0,
                        weekly: weekly,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Transform.translate(
                      offset: Offset(0, -_scrollOffset * 0.02),
                      child: _HomeTipsCard(
                        tips: const [
                          'Kurangi 15-30 menit setiap minggu',
                          'Kunci aplikasi paling menganggu saat jam fokus',
                          'Gunakan mode fokus pagi & malam',
                          'Rayakan kemenangan kecil harian',
                        ],
                      ),
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

class _HomeHeader extends StatelessWidget {
  final String name;
  final int streak;
  final String quote;
  final int recommendedTarget;
  final String bestDay;

  const _HomeHeader({
    required this.name,
    required this.streak,
    required this.quote,
    required this.recommendedTarget,
    required this.bestDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.9),
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
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
                    Text('Halo, $name 👋',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            )),
                    const SizedBox(height: 4),
                    Text('Kontrol sosial media Anda',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                    const SizedBox(width: 6),
                    Text('$streak hari', 
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('TARGET HARIAN',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  )),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$recommendedTarget',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('menit/hari', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Paling produktif $bestDay',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '“$quote”',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final List<_QuickActionData> actions;

  const _QuickActionsGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 48) / 2;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions
          .map(
            (action) => SizedBox(
              width: cardWidth,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      action.color.withOpacity(0.05),
                      action.color.withOpacity(0.02),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: action.color.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: action.color.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: action.onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  action.color.withOpacity(0.15),
                                  action.color.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: action.color.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(action.icon, color: action.color, size: 24),
                          ),
                          const SizedBox(height: 16),
                          Text(action.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  )),
                          const SizedBox(height: 6),
                          Text(action.subtitle, 
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _ActiveChallengeHighlight extends StatelessWidget {
  final UserChallenge? userChallenge;
  final Challenge? challengeDetail;
  final VoidCallback onSeeAll;

  const _ActiveChallengeHighlight({
    required this.userChallenge,
    required this.challengeDetail,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (userChallenge == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.primary.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.flag_outlined, 
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Belum ada challenge aktif',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      )),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Mulai tantangan baru untuk menjaga fokus detoks sosial media.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: FilledButton(
                  onPressed: onSeeAll,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lihat Challenge',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalDays = userChallenge!.endDate == null
        ? userChallenge!.currentDay
        : (userChallenge!.endDate!
                .difference(userChallenge!.startDate)
                .inDays +
            1)
            .clamp(1, 3650);
    final progress = totalDays == 0 ? 0.0 : (userChallenge!.currentDay / totalDays).clamp(0.0, 1.0);
    final title =
        challengeDetail?.challengeName ?? userChallenge!.category.replaceAll('_', ' ').toUpperCase();
    final subtitle = challengeDetail?.description ?? 'Tetap konsisten per hari';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('${userChallenge!.successDays} sukses',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hari ${userChallenge!.currentDay}/$totalDays',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Mulai ${userChallenge!.startDate.day}/${userChallenge!.startDate.month}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kelola Challenge',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAnalyticsPreview extends StatelessWidget {
  final int totalPoints;
  final int completedChallenges;
  final int longestStreak;
  final List<DailyCheckInStat> weekly;

  const _HomeAnalyticsPreview({
    required this.totalPoints,
    required this.completedChallenges,
    required this.longestStreak,
    required this.weekly,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ringkasan Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                    );
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Total Poin',
                    value: '$totalPoints',
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: 'Challenge',
                    value: '$completedChallenges',
                    icon: Icons.flag,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: 'Streak Max',
                    value: '$longestStreak',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Check-in 7 Hari Terakhir', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (weekly.isEmpty)
              const SizedBox(
                height: 150,
                child: Center(child: Text('Belum ada data minggu ini')),
              )
            else
              CheckinBarChart(data: weekly),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            foregroundColor: color,
            child: Icon(icon, size: 20),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _HomeTipsCard extends StatelessWidget {
  final List<String> tips;

  const _HomeTipsCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A18), Color(0xFFFFA94F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tips Sukses',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $tip', style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}


