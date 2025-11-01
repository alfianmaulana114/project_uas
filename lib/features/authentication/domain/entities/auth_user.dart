import 'package:equatable/equatable.dart';

/// Entity untuk representasi user yang terautentikasi
/// Menggunakan Equatable untuk value comparison
/// Mengikuti konsep Clean Architecture - Domain Layer
class AuthUser extends Equatable {
  /// Unique identifier user
  final String id;

  /// Email user (unique)
  final String email;

  /// Nama lengkap user
  final String? fullName;

  /// Username user (unique)
  final String? username;

  /// URL avatar user
  final String? avatarUrl;

  /// Total points yang dimiliki user
  final int totalPoints;

  /// Current streak user
  final int currentStreak;

  /// Longest streak user
  final int longestStreak;

  /// Constructor untuk AuthUser
  const AuthUser({
    required this.id,
    required this.email,
    this.fullName,
    this.username,
    this.avatarUrl,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  /// Override props untuk Equatable comparison
  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        username,
        avatarUrl,
        totalPoints,
        currentStreak,
        longestStreak,
      ];

  /// CopyWith method untuk membuat instance baru dengan beberapa perubahan
  /// Mengikuti konsep immutability
  AuthUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? avatarUrl,
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
  }) {
    return AuthUser(
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

