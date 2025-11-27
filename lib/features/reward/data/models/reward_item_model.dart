import '../../domain/entities/reward_item.dart';

class RewardItemModel extends RewardItem {
  const RewardItemModel({
    required super.id,
    required super.name,
    super.description,
    required super.category,
    required super.pointsRequired,
    required super.stock,
    super.imageUrl,
    super.icon,
    super.createdAt,
    super.updatedAt,
  });

  factory RewardItemModel.fromJson(Map<String, dynamic> json) {
    return RewardItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      pointsRequired: json['points_required'] as int,
      stock: json['stock'] as int,
      imageUrl: json['image_url'] as String?,
      icon: json['icon'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'points_required': pointsRequired,
      'stock': stock,
      'image_url': imageUrl,
      'icon': icon,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

