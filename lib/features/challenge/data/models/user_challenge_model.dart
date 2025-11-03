import '../../domain/entities/user_challenge.dart';

class UserChallengeModel extends UserChallenge {
  const UserChallengeModel({
    required super.id,
    required super.userId,
    required super.challengeId,
    required super.category,
    required super.startDate,
    required super.endDate,
    required super.status,
    required super.currentDay,
    required super.successDays,
    required super.pointsEarned,
    required super.bookName,
    required super.eventName,
    required super.completedAt,
    required super.createdAt,
  });

  factory UserChallengeModel.fromJson(Map<String, dynamic> json) {
    return UserChallengeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      challengeId: json['challenge_id'] as String,
      category: json['category'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null ? null : DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
      currentDay: (json['current_day'] as num).toInt(),
      successDays: (json['success_days'] as num).toInt(),
      pointsEarned: (json['points_earned'] as num).toInt(),
      bookName: json['book_name'] as String?,
      eventName: json['event_name'] as String?,
      completedAt: json['completed_at'] == null ? null : DateTime.parse(json['completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}


