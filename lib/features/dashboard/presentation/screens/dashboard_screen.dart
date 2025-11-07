import 'package:flutter/material.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import 'package:provider/provider.dart';
import '../../../challenge/presentation/providers/challenge_provider.dart';
import '../../../challenge/presentation/screens/challenge_list_screen.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _HomeTab(),
      const ChallengeListScreen(),
      const AnalyticsScreen(),
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
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selamat datang!'),
            const SizedBox(height: 8),
            Consumer<ChallengeProvider>(
              builder: (ctx, p, _) => Text('Challenge aktif: ${p.activeChallenges.length}'),
            ),
            const SizedBox(height: 8),
            Consumer<AuthProvider>(
              builder: (ctx, a, _) => Column(
                children: [
                  Text('Streak saat ini: ${a.currentUser?.currentStreak ?? 0}'),
                  Text('Longest streak: ${a.currentUser?.longestStreak ?? 0}'),
                  Text('Total poin: ${a.currentUser?.totalPoints ?? 0}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


