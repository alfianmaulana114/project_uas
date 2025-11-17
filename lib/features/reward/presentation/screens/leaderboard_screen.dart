import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reward_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/leaderboard_entry.dart';

/// Leaderboard Screen
/// Menampilkan ranking pengguna berdasarkan berbagai metrik
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RewardProvider>().loadLeaderboard();
    });
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'points':
        return 'Poin';
      case 'streak':
        return 'Streak';
      case 'challenges':
        return 'Challenge';
      case 'checkins':
        return 'Check-in';
      default:
        return 'Poin';
    }
  }

  IconData _getSortIcon(String sortBy) {
    switch (sortBy) {
      case 'points':
        return Icons.stars;
      case 'streak':
        return Icons.local_fire_department;
      case 'challenges':
        return Icons.flag;
      case 'checkins':
        return Icons.check_circle;
      default:
        return Icons.stars;
    }
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.looks_one, color: Colors.white),
      );
    } else if (rank == 2) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.looks_two, color: Colors.white),
      );
    } else if (rank == 3) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.brown[400],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.looks_3, color: Colors.white),
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, bool isCurrentUser) {
    return Card(
      color: isCurrentUser
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildRankBadge(entry.rank),
        title: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              child: entry.avatarUrl == null
                  ? Text(
                      entry.displayName.isNotEmpty
                          ? entry.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.displayName,
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  if (isCurrentUser)
                    Text(
                      'Anda',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _getValueBySort(entry),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              _getLabelBySort(),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip(Icons.stars, '${entry.totalPoints} poin'),
              _buildStatChip(Icons.local_fire_department, '${entry.currentStreak} hari'),
              _buildStatChip(Icons.flag, '${entry.completedChallenges}'),
              _buildStatChip(Icons.check_circle, '${entry.totalCheckins}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getValueBySort(LeaderboardEntry entry) {
    final sortBy = context.read<RewardProvider>().leaderboardSortBy;
    switch (sortBy) {
      case 'points':
        return '${entry.totalPoints}';
      case 'streak':
        return '${entry.currentStreak}';
      case 'challenges':
        return '${entry.completedChallenges}';
      case 'checkins':
        return '${entry.totalCheckins}';
      default:
        return '${entry.totalPoints}';
    }
  }

  String _getLabelBySort() {
    return _getSortLabel(context.read<RewardProvider>().leaderboardSortBy);
  }

  @override
  Widget build(BuildContext context) {
    final rewardProvider = context.watch<RewardProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(_getSortIcon(rewardProvider.leaderboardSortBy)),
            tooltip: 'Sort by',
            onSelected: (value) {
              rewardProvider.loadLeaderboard(sortBy: value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'points',
                child: Row(
                  children: [
                    Icon(Icons.stars),
                    SizedBox(width: 8),
                    Text('Poin'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'streak',
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department),
                    SizedBox(width: 8),
                    Text('Streak'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'challenges',
                child: Row(
                  children: [
                    Icon(Icons.flag),
                    SizedBox(width: 8),
                    Text('Challenge'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'checkins',
                child: Row(
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: 8),
                    Text('Check-in'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => rewardProvider.loadLeaderboard(),
        child: Column(
          children: [
            // Header dengan sort info
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(
                    _getSortIcon(rewardProvider.leaderboardSortBy),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Diurutkan berdasarkan: ${_getSortLabel(rewardProvider.leaderboardSortBy)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            // Leaderboard list
            if (rewardProvider.isLeaderboardLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (rewardProvider.leaderboardError != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        rewardProvider.leaderboardError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => rewardProvider.loadLeaderboard(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else if (rewardProvider.leaderboard.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.leaderboard_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data leaderboard',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: rewardProvider.leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = rewardProvider.leaderboard[index];
                    final isCurrentUser = entry.userId == currentUserId;
                    return _buildLeaderboardItem(entry, isCurrentUser);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

