import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_user.dart';

/// Model untuk representasi user yang terautentikasi di Data Layer
/// Extends dari AuthUser entity (Domain Layer)
/// Menggunakan factory pattern untuk conversion dari/to JSON
/// Mengikuti konsep Clean Architecture - Data Layer
class AuthUserModel extends AuthUser with EquatableMixin {
  /// Constructor untuk AuthUserModel
  const AuthUserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.username,
    super.avatarUrl,
    super.totalPoints = 0,
    super.currentStreak = 0,
    super.longestStreak = 0,
  });

  /// Factory constructor untuk membuat AuthUserModel dari JSON
  /// [json] adalah Map<String, dynamic> dari Supabase response
  /// Menggunakan factory pattern untuk object creation
  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      totalPoints: (json['total_points'] as int?) ?? 0,
      currentStreak: (json['current_streak'] as int?) ?? 0,
      longestStreak: (json['longest_streak'] as int?) ?? 0,
    );
  }

  /// Method untuk convert AuthUserModel ke JSON
  /// Mengembalikan Map<String, dynamic> untuk dikirim ke Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'total_points': totalPoints,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }

  /// Factory constructor untuk membuat AuthUserModel dari AuthUser entity
  /// Digunakan untuk conversion dari Domain Layer ke Data Layer
  factory AuthUserModel.fromEntity(AuthUser user) {
    return AuthUserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      username: user.username,
      avatarUrl: user.avatarUrl,
      totalPoints: user.totalPoints,
      currentStreak: user.currentStreak,
      longestStreak: user.longestStreak,
    );
  }

  /// CopyWith method untuk membuat instance baru dengan beberapa perubahan
  /// Mengikuti konsep immutability
  @override
  AuthUserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? avatarUrl,
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }
}

