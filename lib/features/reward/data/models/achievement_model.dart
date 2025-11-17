import '../../domain/entities/achievement.dart';

class AchievementModel {
  final String id;
  final String name;
  final String? description;
  final String? badgeIcon;
  final String requirementType;
  final int requirementValue;
  final int pointsReward;
  final DateTime? createdAt;

  AchievementModel({
    required this.id,
    required this.name,
    this.description,
    this.badgeIcon,
    required this.requirementType,
    required this.requirementValue,
    required this.pointsReward,
    this.createdAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: (json['achievement_name'] ?? json['name']) as String,
      description: json['description'] as String?,
      badgeIcon: json['badge_icon'] as String?,
      requirementType: json['requirement_type'] as String,
      requirementValue: (json['requirement_value'] ?? 0) as int,
      pointsReward: (json['points_reward'] ?? 0) as int,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Achievement toEntity() => Achievement(
        id: id,
        name: name,
        description: description,
        badgeIcon: badgeIcon,
        requirementType: requirementType,
        requirementValue: requirementValue,
        pointsReward: pointsReward,
        createdAt: createdAt,
      );
}