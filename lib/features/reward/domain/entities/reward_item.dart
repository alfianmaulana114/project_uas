import 'package:equatable/equatable.dart';

/// Reward Item Entity
/// Menyimpan data reward yang bisa ditukar dengan poin
class RewardItem extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String category; // 'voucher' | 'hadiah'
  final int pointsRequired;
  final int stock;
  final String? imageUrl;
  final String? icon; // Icon name untuk reward
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RewardItem({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.pointsRequired,
    required this.stock,
    this.imageUrl,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        pointsRequired,
        stock,
        imageUrl,
        icon,
        createdAt,
        updatedAt,
      ];
}

