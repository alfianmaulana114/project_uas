import 'package:equatable/equatable.dart';

/// Entity untuk representasi challenge
/// Menggunakan Equatable untuk value comparison
/// Mengikuti konsep Clean Architecture - Domain Layer
class Challenge extends Equatable {
  /// Unique identifier challenge
  final String id;

  /// Nama challenge
  final String challengeName;

  /// Deskripsi challenge (opsional)
  final String? description;

  /// Durasi challenge dalam hari
  final int durationDays;

  /// Poin reward yang didapat setelah menyelesaikan challenge (opsional)
  final int? pointsReward;

  /// Icon name untuk challenge (opsional)
  final String? icon;

  /// Kategori challenge
  /// 'social_media' | 'olahraga' | 'bersosialisasi' | 'membaca_buku'
  final String category;

  /// Tanggal challenge dibuat
  final DateTime createdAt;

  /// Constructor untuk Challenge
  const Challenge({
    required this.id,
    required this.challengeName,
    this.description,
    required this.durationDays,
    this.pointsReward,
    this.icon,
    required this.category,
    required this.createdAt,
  });

  /// Override props untuk Equatable comparison
  @override
  List<Object?> get props => [
        id,
        challengeName,
        description,
        durationDays,
        pointsReward,
        icon,
        category,
        createdAt,
      ];

  /// CopyWith method untuk membuat instance baru dengan beberapa perubahan
  /// Mengikuti konsep immutability
  Challenge copyWith({
    String? id,
    String? challengeName,
    String? description,
    int? durationDays,
    int? pointsReward,
    String? icon,
    String? category,
    DateTime? createdAt,
  }) {
    return Challenge(
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


