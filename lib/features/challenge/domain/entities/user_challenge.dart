import 'package:equatable/equatable.dart';

/// Entity untuk representasi user challenge (challenge yang diikuti oleh user)
/// Menggunakan Equatable untuk value comparison
/// Mengikuti konsep Clean Architecture - Domain Layer
class UserChallenge extends Equatable {
  /// Unique identifier user challenge
  final String id;

  /// ID user yang mengikuti challenge
  final String userId;

  /// ID challenge yang diikuti
  final String challengeId;

  /// Kategori challenge (sama dengan enum string)
  /// 'social_media' | 'olahraga' | 'bersosialisasi' | 'membaca_buku'
  final String category;

  /// Tanggal mulai challenge
  final DateTime startDate;

  /// Tanggal berakhir challenge (opsional)
  final DateTime? endDate;

  /// Status challenge
  /// 'active' | 'completed' | 'cancelled'
  final String status;

  /// Hari saat ini dalam challenge
  final int currentDay;

  /// Jumlah hari sukses
  final int successDays;

  /// Poin yang sudah didapat
  final int pointsEarned;

  /// Nama buku (untuk challenge membaca_buku, opsional)
  final String? bookName;

  /// Nama event (untuk challenge bersosialisasi, opsional)
  final String? eventName;

  /// Tanggal challenge selesai (opsional)
  final DateTime? completedAt;

  /// Tanggal user challenge dibuat
  final DateTime createdAt;

  /// Constructor untuk UserChallenge
  const UserChallenge({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.category,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.currentDay,
    required this.successDays,
    required this.pointsEarned,
    this.bookName,
    this.eventName,
    this.completedAt,
    required this.createdAt,
  });

  /// Override props untuk Equatable comparison
  @override
  List<Object?> get props => [
        id,
        userId,
        challengeId,
        category,
        startDate,
        endDate,
        status,
        currentDay,
        successDays,
        pointsEarned,
        bookName,
        eventName,
        completedAt,
        createdAt,
      ];

  /// CopyWith method untuk membuat instance baru dengan beberapa perubahan
  /// Mengikuti konsep immutability
  UserChallenge copyWith({
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
    return UserChallenge(
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


