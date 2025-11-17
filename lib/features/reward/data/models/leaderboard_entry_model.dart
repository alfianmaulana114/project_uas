import '../../domain/entities/leaderboard_entry.dart';

/// Leaderboard Entry Model
/// Model untuk data leaderboard dari Supabase
class LeaderboardEntryModel {
  final String userId;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int completedChallenges;
  final int totalCheckins;
  final int rank;

  LeaderboardEntryModel({
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

  /// Convert dari JSON (Supabase response)
  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json, int rank) {
    return LeaderboardEntryModel(
      userId: json['id'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      totalPoints: (json['total_points'] ?? 0) as int,
      currentStreak: (json['current_streak'] ?? 0) as int,
      longestStreak: (json['longest_streak'] ?? 0) as int,
      completedChallenges: (json['completed_challenges'] ?? 0) as int,
      totalCheckins: (json['total_checkins'] ?? 0) as int,
      rank: rank,
    );
  }

  /// Convert ke Entity
  LeaderboardEntry toEntity() {
    return LeaderboardEntry(
      userId: userId,
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
      totalPoints: totalPoints,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      completedChallenges: completedChallenges,
      totalCheckins: totalCheckins,
      rank: rank,
    );
  }
}

