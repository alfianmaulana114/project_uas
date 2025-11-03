import 'package:equatable/equatable.dart';
import '../../domain/entities/challenge.dart';

/// Model untuk representasi challenge di Data Layer
/// Extends dari Challenge entity (Domain Layer)
/// Menggunakan factory pattern untuk conversion dari/to JSON
/// Mengikuti konsep Clean Architecture - Data Layer
class ChallengeModel extends Challenge with EquatableMixin {
  /// Constructor untuk ChallengeModel
  const ChallengeModel({
    required super.id,
    required super.challengeName,
    super.description,
    required super.durationDays,
    super.pointsReward,
    super.icon,
    required super.category,
    required super.createdAt,
  });

  /// Factory constructor untuk membuat ChallengeModel dari JSON
  /// [json] adalah Map<String, dynamic> dari Supabase response
  /// Menggunakan factory pattern untuk object creation
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

  /// Method untuk convert ChallengeModel ke JSON
  /// Mengembalikan Map<String, dynamic> untuk dikirim ke Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challenge_name': challengeName,
      'description': description,
      'duration_days': durationDays,
      'points_reward': pointsReward,
      'icon': icon,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Factory constructor untuk membuat ChallengeModel dari Challenge entity
  /// Digunakan untuk conversion dari Domain Layer ke Data Layer
  factory ChallengeModel.fromEntity(Challenge challenge) {
    return ChallengeModel(
      id: challenge.id,
      challengeName: challenge.challengeName,
      description: challenge.description,
      durationDays: challenge.durationDays,
      pointsReward: challenge.pointsReward,
      icon: challenge.icon,
      category: challenge.category,
      createdAt: challenge.createdAt,
    );
  }

  /// CopyWith method untuk membuat instance baru dengan beberapa perubahan
  /// Mengikuti konsep immutability
  @override
  ChallengeModel copyWith({
    String? id,
    String? challengeName,
    String? description,
    int? durationDays,
    int? pointsReward,
    String? icon,
    String? category,
    DateTime? createdAt,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      challengeName: challengeName ?? this.challengeName,
      description: description ?? this.description,
      durationDays: durationDays ?? this.durationDays,
      pointsReward: pointsReward ?? this.pointsReward,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


