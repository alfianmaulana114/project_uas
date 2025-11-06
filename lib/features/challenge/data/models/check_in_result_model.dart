import '../../domain/entities/check_in_result.dart';

class CheckInResultModel extends CheckInResult {
  const CheckInResultModel({
    required super.userChallengeId,
    required super.isSuccess,
    required super.alreadyCheckedInToday,
    required super.challengeCompleted,
    required super.pointsAwarded,
    required super.status,
    required super.currentDay,
    required super.successDays,
    required super.currentStreak,
    required super.longestStreak,
    required super.totalPoints,
  });

  factory CheckInResultModel.fromJson(Map<String, dynamic> json) {
    final uc = (json['user_challenge'] ?? const {}) as Map<String, dynamic>;
    return CheckInResultModel(
      userChallengeId: (uc['id'] ?? json['user_challenge_id']) as String,
      isSuccess: (json['is_success'] as bool?) ?? true,
      alreadyCheckedInToday: (json['already_checked_in_today'] as bool?) ?? false,
      challengeCompleted: (json['challenge_completed'] as bool?) ?? false,
      pointsAwarded: (json['points_awarded'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? uc['status']) as String,
      currentDay: (json['current_day'] ?? uc['current_day'] ?? 1 as Object) is num
          ? ((json['current_day'] ?? uc['current_day']) as num).toInt()
          : 1,
      successDays: (json['success_days'] ?? uc['success_days'] ?? 0 as Object) is num
          ? ((json['success_days'] ?? uc['success_days']) as num).toInt()
          : 0,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
    );
  }
}