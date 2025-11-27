import '../../domain/entities/reward_redemption.dart';

class RewardRedemptionModel extends RewardRedemption {
  const RewardRedemptionModel({
    required super.id,
    required super.userId,
    required super.rewardItemId,
    required super.rewardName,
    required super.pointsUsed,
    required super.status,
    required super.redeemedAt,
    super.completedAt,
  });

  factory RewardRedemptionModel.fromJson(Map<String, dynamic> json) {
    return RewardRedemptionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      rewardItemId: json['reward_item_id'] as String,
      rewardName: json['reward_name'] as String,
      pointsUsed: json['points_used'] as int,
      status: json['status'] as String,
      redeemedAt: DateTime.parse(json['redeemed_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reward_item_id': rewardItemId,
      'reward_name': rewardName,
      'points_used': pointsUsed,
      'status': status,
      'redeemed_at': redeemedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

