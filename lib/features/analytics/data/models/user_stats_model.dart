import '../../domain/entities/user_stats.dart';

class UserStatsModel extends UserStats {
  const UserStatsModel({
    required super.userId,
    required super.totalPoints,
    required super.currentStreak,
    required super.longestStreak,
    required super.completedChallenges,
    required super.activitiesCompleted,
    required super.badgesEarned,
  });

  factory UserStatsModel.fromMap(Map<String, dynamic> map) {
    return UserStatsModel(
      userId: map['user_id']?.toString() ?? '',
      totalPoints: (map['total_points'] ?? 0) as int,
      currentStreak: (map['current_streak'] ?? 0) as int,
      longestStreak: (map['longest_streak'] ?? 0) as int,
      completedChallenges: (map['completed_challenges'] ?? 0) as int,
      activitiesCompleted: (map['activities_completed'] ?? 0) as int,
      badgesEarned: (map['badges_earned'] ?? 0) as int,
    );
  }
}