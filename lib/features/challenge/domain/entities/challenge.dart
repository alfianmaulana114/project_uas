class Challenge {
  final String id;
  final String challengeName;
  final String? description;
  final int durationDays;
  final int? pointsReward;
  final String? icon;
  final String category; // 'social_media' | 'olahraga' | 'bersosialisasi' | 'membaca_buku'
  final DateTime createdAt;

  const Challenge({
    required this.id,
    required this.challengeName,
    required this.description,
    required this.durationDays,
    required this.pointsReward,
    required this.icon,
    required this.category,
    required this.createdAt,
  });
}


