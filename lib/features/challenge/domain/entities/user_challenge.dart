class UserChallenge {
  final String id;
  final String userId;
  final String challengeId;
  final String category; // same as enum string
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // 'active' | 'completed' | 'cancelled'
  final int currentDay;
  final int successDays;
  final int pointsEarned;
  final String? bookName;
  final String? eventName;
  final DateTime? completedAt;
  final DateTime createdAt;

  const UserChallenge({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.currentDay,
    required this.successDays,
    required this.pointsEarned,
    required this.bookName,
    required this.eventName,
    required this.completedAt,
    required this.createdAt,
  });
}


