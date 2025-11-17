import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../challenge/presentation/screens/challenge_list_screen.dart';
<<<<<<< HEAD
import '../../../challenge/presentation/widgets/active_challenge_card.dart';
=======
import '../../../challenge/presentation/providers/challenge_provider.dart';
import '../widgets/motivational_empty_state.dart';
import '../widgets/progress_summary_widget.dart';
>>>>>>> 3b97d0edc0d8b342bc3290bde799bd32e26541a6

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
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
<<<<<<< HEAD
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Challenge',
          ),
=======
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Challenge'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Analytics'),
>>>>>>> 3b97d0edc0d8b342bc3290bde799bd32e26541a6
        ],
      ),
    );
  }
}

<<<<<<< HEAD
/// Home Tab
/// Menampilkan dashboard home dengan active challenges
class _HomeTab extends StatefulWidget {
  /// Constructor untuk _HomeTab
  const _HomeTab();

=======
class _HomeTab extends StatefulWidget {
  final VoidCallback onNavigateToChallenges;
  
  const _HomeTab({required this.onNavigateToChallenges});
  
>>>>>>> 3b97d0edc0d8b342bc3290bde799bd32e26541a6
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    /// Load challenges saat screen pertama kali dibuka
=======
    // Load challenge data saat home dibuka
>>>>>>> 3b97d0edc0d8b342bc3290bde799bd32e26541a6
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ChallengeProvider>().refresh(),
        child: Consumer<ChallengeProvider>(
          builder: (context, provider, _) {
            /// Jika sedang loading
            if (provider.isLoading && provider.activeChallenges.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// Welcome message
                const Text(
                  'Selamat datang!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Challenge aktif: ${provider.activeChallenges.length}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                /// Active Challenges Section
                if (provider.activeChallenges.isNotEmpty) ...[
                  const Text(
                    'Challenge Aktif',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...provider.activeChallenges.map(
                    (userChallenge) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ActiveChallengeCard(userChallenge: userChallenge),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  /// Empty state
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada challenge aktif',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulai challenge baru untuk mengembangkan diri!',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                /// Error message
                if (provider.error != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
=======
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Widget motivasional (muncul jika poin/streak = 0)
            MotivationalEmptyState(onNavigateToChallenges: widget.onNavigateToChallenges),
            
            const SizedBox(height: 16),
            // Ringkasan Progress yang Lebih Visual
            ProgressSummaryWidget(onNavigateToChallenges: widget.onNavigateToChallenges),
          ],
>>>>>>> 3b97d0edc0d8b342bc3290bde799bd32e26541a6
        ),
      ),
    );
  }
}


