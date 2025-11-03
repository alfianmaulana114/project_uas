import '../../domain/entities/challenge.dart';

class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.challengeName,
    required super.description,
    required super.durationDays,
    required super.pointsReward,
    required super.icon,
    required super.category,
    required super.createdAt,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      challengeName: json['challenge_name'] as String,
      description: json['description'] as String?,
      durationDays: (json['duration_days'] as num).toInt(),
      pointsReward: json['points_reward'] == null ? null : (json['points_reward'] as num).toInt(),
      icon: json['icon'] as String?,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}


