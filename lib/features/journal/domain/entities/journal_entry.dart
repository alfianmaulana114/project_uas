import 'package:equatable/equatable.dart';

/// Entity untuk representasi journal entry (catatan mood)
class JournalEntry extends Equatable {
  final String id;
  final String userId;
  final int mood; // 1-5 (1 = sangat buruk, 5 = sangat baik)
  final String note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.mood,
    required this.note,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, mood, note, createdAt, updatedAt];

  JournalEntry copyWith({
    String? id,
    String? userId,
    int? mood,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

