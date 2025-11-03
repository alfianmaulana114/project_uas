import 'package:equatable/equatable.dart';
import '../../domain/entities/user_challenge.dart';

/// Model untuk representasi user challenge di Data Layer
/// Extends dari UserChallenge entity (Domain Layer)
/// Menggunakan factory pattern untuk conversion dari/to JSON
/// Mengikuti konsep Clean Architecture - Data Layer
class UserChallengeModel extends UserChallenge with EquatableMixin {
  /// Constructor untuk UserChallengeModel
  const UserChallengeModel({
    required super.id,
    required super.userId,
    required super.challengeId,
    required super.category,
    required super.startDate,
    super.endDate,
    required super.status,
    required super.currentDay,
    required super.successDays,
    required super.pointsEarned,
    super.bookName,
    super.eventName,
    super.completedAt,
    required super.createdAt,
  });

  /// Factory constructor untuk membuat UserChallengeModel dari JSON
  /// [json] adalah Map<String, dynamic> dari Supabase response
  /// Menggunakan factory pattern untuk object creation
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

  /// Method untuk convert UserChallengeModel ke JSON
  /// Mengembalikan Map<String, dynamic> untuk dikirim ke Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'challenge_id': challengeId,
      'category': category,
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate?.toIso8601String().substring(0, 10),
      'status': status,
      'current_day': currentDay,
      'success_days': successDays,
      'points_earned': pointsEarned,
      'book_name': bookName,
      'event_name': eventName,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Factory constructor untuk membuat UserChallengeModel dari UserChallenge entity
  /// Digunakan untuk conversion dari Domain Layer ke Data Layer
  factory UserChallengeModel.fromEntity(UserChallenge userChallenge) {
    return UserChallengeModel(
      id: userChallenge.id,
      userId: userChallenge.userId,
      challengeId: userChallenge.challengeId,
      category: userChallenge.category,
      startDate: userChallenge.startDate,
      endDate: userChallenge.endDate,
      status: userChallenge.status,
      currentDay: userChallenge.currentDay,
      successDays: userChallenge.successDays,
      pointsEarned: userChallenge.pointsEarned,
      bookName: userChallenge.bookName,
      eventName: userChallenge.eventName,
      completedAt: userChallenge.completedAt,
      createdAt: userChallenge.createdAt,
    );
  }

  /// CopyWith method untuk membuat instance baru dengan beberapa perubahan
  /// Mengikuti konsep immutability
  @override
  UserChallengeModel copyWith({
    String? id,
    String? userId,
    String? challengeId,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int? currentDay,
    int? successDays,
    int? pointsEarned,
    String? bookName,
    String? eventName,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return UserChallengeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      currentDay: currentDay ?? this.currentDay,
      successDays: successDays ?? this.successDays,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      bookName: bookName ?? this.bookName,
      eventName: eventName ?? this.eventName,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


