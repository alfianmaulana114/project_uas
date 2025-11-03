import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../widgets/challenge_card.dart';
import '../widgets/active_challenge_card.dart';

/// Challenge List Screen
/// Screen untuk menampilkan daftar semua challenges dan active challenges
/// Mengikuti konsep Single Responsibility Principle
class ChallengeListScreen extends StatefulWidget {
  /// Constructor untuk ChallengeListScreen
  const ChallengeListScreen({super.key});

  @override
  State<ChallengeListScreen> createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen> {
  final List<Map<String, String?>> _categories = const [
    {'label': 'Semua', 'value': null},
    {'label': 'Social Media', 'value': 'social_media'},
    {'label': 'Olahraga', 'value': 'olahraga'},
    {'label': 'Bersosialisasi', 'value': 'bersosialisasi'},
    {'label': 'Membaca Buku', 'value': 'membaca_buku'},
  ];

  String? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge'),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.load(category: _selected),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              children: _categories.map((c) {
                final selected = _selected == c['value'];
                return ChoiceChip(
                  label: Text(c['label']!),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selected = c['value']);
                    provider.load(category: _selected);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (provider.activeChallenges.isNotEmpty) ...[
              const Text('Aktif Saat Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final uc in provider.activeChallenges)
                ActiveChallengeCard(userChallenge: uc),
              const SizedBox(height: 16),
            ],
            const Text('Semua Challenge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (provider.challenges.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Tidak ada challenge')),
              )
            else
              ...provider.challenges.map((ch) => ChallengeCard(challenge: ch)).toList(),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(provider.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
    );
  }
}


