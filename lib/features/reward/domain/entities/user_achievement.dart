import 'package:equatable/equatable.dart';

class UserAchievement extends Equatable {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime? earnedAt;

  const UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    this.earnedAt,
  });

  @override
  List<Object?> get props => [id, userId, achievementId, earnedAt];
}