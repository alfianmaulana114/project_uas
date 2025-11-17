import '../../domain/entities/user_achievement.dart';

class UserAchievementModel {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime? earnedAt;

  UserAchievementModel({
    required this.id,
    required this.userId,
    required this.achievementId,
    this.earnedAt,
  });

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      earnedAt: json['earned_at'] != null ? DateTime.parse(json['earned_at'] as String) : null,
    );
  }

  UserAchievement toEntity() => UserAchievement(
        id: id,
        userId: userId,
        achievementId: achievementId,
        earnedAt: earnedAt,
      );
}