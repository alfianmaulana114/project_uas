import '../../domain/entities/journal_entry.dart';

/// Model untuk journal entry dari Supabase
class JournalEntryModel extends JournalEntry {
  const JournalEntryModel({
    required super.id,
    required super.userId,
    required super.mood,
    required super.note,
    required super.createdAt,
    super.updatedAt,
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    // Convert mood dari varchar ke int (1-5)
    int moodInt;
    if (json['mood'] is String) {
      moodInt = int.tryParse(json['mood'] as String) ?? 3;
    } else {
      moodInt = json['mood'] as int;
    }
    
    return JournalEntryModel(
      id: json['id'].toString(), // UUID to String
      userId: json['user_id'].toString(), // UUID to String
      mood: moodInt,
      note: json['entry_text'] as String? ?? '', // entry_text bukan note
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (json['entry_date'] != null
              ? DateTime.parse(json['entry_date'] as String)
              : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'mood': mood.toString(), // Convert int ke varchar
      'entry_text': note, // entry_text bukan note
      'entry_date': createdAt.toIso8601String().substring(0, 10), // YYYY-MM-DD format
      'created_at': createdAt.toIso8601String(),
    };
    
    // Hanya kirim id jika tidak kosong (biarkan Supabase generate UUID)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    if (updatedAt != null) {
      json['updated_at'] = updatedAt!.toIso8601String();
    }
    
    return json;
  }

  JournalEntryModel copyWith({
    String? id,
    String? userId,
    int? mood,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

