class CheckInResult {
  final String userChallengeId;
  final bool isSuccess;
  final bool alreadyCheckedInToday;
  final bool challengeCompleted;
  final int pointsAwarded;

  /// Updated challenge snapshot
  final String status; // 'active' | 'completed' | 'cancelled'
  final int currentDay;
  final int successDays;

  /// Updated user stats
  final int currentStreak;
  final int longestStreak;
  final int totalPoints;

  const CheckInResult({
    required this.userChallengeId,
    required this.isSuccess,
    required this.alreadyCheckedInToday,
    required this.challengeCompleted,
    required this.pointsAwarded,
    required this.status,
    required this.currentDay,
    required this.successDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
  });
}