import 'package:equatable/equatable.dart';

/// Leaderboard Entry Entity
/// Menyimpan data ranking user di leaderboard
class LeaderboardEntry extends Equatable {
  final String userId;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int completedChallenges;
  final int totalCheckins;
  final int rank; // Posisi di leaderboard (1, 2, 3, dst)

  const LeaderboardEntry({
    required this.userId,
    this.username,
    this.fullName,
    this.avatarUrl,
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedChallenges,
    required this.totalCheckins,
    required this.rank,
  });

  /// Display name: username jika ada, jika tidak fullName, jika tidak "User"
  String get displayName {
    if (username != null && username!.isNotEmpty) return username!;
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    return 'User';
  }

  @override
  List<Object?> get props => [
        userId,
        username,
        fullName,
        avatarUrl,
        totalPoints,
        currentStreak,
        longestStreak,
        completedChallenges,
        totalCheckins,
        rank,
      ];
}

