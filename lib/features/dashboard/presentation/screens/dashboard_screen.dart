import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../challenge/presentation/providers/challenge_provider.dart';
import '../../../challenge/presentation/screens/challenge_list_screen.dart';
import '../../../challenge/presentation/widgets/active_challenge_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _HomeTab(),
      const ChallengeListScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
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
        ],
      ),
    );
  }
}

/// Home Tab
/// Menampilkan dashboard home dengan active challenges
class _HomeTab extends StatefulWidget {
  /// Constructor untuk _HomeTab
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  void initState() {
    super.initState();
    /// Load challenges saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
      ),
    );
  }
}


