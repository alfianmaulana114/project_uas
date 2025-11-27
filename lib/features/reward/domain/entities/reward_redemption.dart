import 'package:equatable/equatable.dart';

/// Reward Redemption Entity
/// Menyimpan data penukaran reward yang dilakukan user
class RewardRedemption extends Equatable {
  final String id;
  final String userId;
  final String rewardItemId;
  final String rewardName;
  final int pointsUsed;
  final String status; // 'pending' | 'processing' | 'completed' | 'cancelled'
  final DateTime redeemedAt;
  final DateTime? completedAt;

  const RewardRedemption({
    required this.id,
    required this.userId,
    required this.rewardItemId,
    required this.rewardName,
    required this.pointsUsed,
    required this.status,
    required this.redeemedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        rewardItemId,
        rewardName,
        pointsUsed,
        status,
        redeemedAt,
        completedAt,
      ];
}

