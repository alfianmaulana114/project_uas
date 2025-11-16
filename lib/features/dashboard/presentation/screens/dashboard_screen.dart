import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../challenge/presentation/screens/challenge_list_screen.dart';
import '../../../challenge/presentation/providers/challenge_provider.dart';
import '../widgets/motivational_empty_state.dart';
import '../widgets/progress_summary_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Challenge'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Analytics'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final VoidCallback onNavigateToChallenges;
  
  const _HomeTab({required this.onNavigateToChallenges});
  
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  void initState() {
    super.initState();
    // Load challenge data saat home dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
      ),
    );
  }
}


