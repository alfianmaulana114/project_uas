class UserStats {
  final String userId;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int completedChallenges;
  final int activitiesCompleted;
  final int badgesEarned;

  const UserStats({
    required this.userId,
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedChallenges,
    required this.activitiesCompleted,
    required this.badgesEarned,
  });
}