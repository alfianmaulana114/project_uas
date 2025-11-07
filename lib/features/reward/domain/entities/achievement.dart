import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? badgeIcon;
  final String requirementType; // e.g., first_checkin, check_in_days, complete_challenge, streak_days
  final int requirementValue;
  final int pointsReward;
  final DateTime? createdAt;

  const Achievement({
    required this.id,
    required this.name,
    this.description,
    this.badgeIcon,
    required this.requirementType,
    required this.requirementValue,
    required this.pointsReward,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        badgeIcon,
        requirementType,
        requirementValue,
        pointsReward,
        createdAt,
      ];
}