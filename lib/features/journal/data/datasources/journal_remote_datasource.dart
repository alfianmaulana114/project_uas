import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/journal_entry_model.dart';

/// Abstract class untuk remote datasource journal
abstract class JournalRemoteDatasource {
  Future<List<JournalEntryModel>> getAllEntries(String userId);
  Future<JournalEntryModel> createEntry(JournalEntryModel entry);
  Future<JournalEntryModel> updateEntry(JournalEntryModel entry);
  Future<void> deleteEntry(String entryId);
  Future<JournalEntryModel?> getEntryByDate(String userId, DateTime date);
}

/// Implementation dari JournalRemoteDatasource menggunakan Supabase
class JournalRemoteDatasourceImpl implements JournalRemoteDatasource {
  @override
  Future<List<JournalEntryModel>> getAllEntries(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final data = (response as List).cast<Map<String, dynamic>>();
      return data.map((json) => JournalEntryModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Gagal mengambil catatan mood: $e');
    }
  }

  @override
  Future<JournalEntryModel> createEntry(JournalEntryModel entry) async {
    try {
      final dataToInsert = entry.toJson();
      
      // Jika id kosong atau bukan UUID format, biarkan Supabase generate UUID
      // Atau gunakan UUID dari entry.id jika sudah valid
      if (entry.id.isEmpty || !entry.id.contains('-')) {
        // Hapus id dari dataToInsert, biarkan Supabase generate
        dataToInsert.remove('id');
      }

      final response = await SupabaseConfig.client
          .from('journal_entries')
          .insert(dataToInsert)
          .select()
          .single();

      return JournalEntryModel.fromJson(response);
    } catch (e) {
      throw ServerException('Gagal menyimpan catatan mood: $e');
    }
  }

  @override
  Future<JournalEntryModel> updateEntry(JournalEntryModel entry) async {
    try {
      final response = await SupabaseConfig.client
          .from('journal_entries')
          .update({
            'mood': entry.mood.toString(), // Convert int ke varchar
            'entry_text': entry.note, // entry_text bukan note
            'entry_date': entry.createdAt.toIso8601String().substring(0, 10),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', entry.id)
          .select()
          .single();

      return JournalEntryModel.fromJson(response);
    } catch (e) {
      throw ServerException('Gagal memperbarui catatan mood: $e');
    }
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    try {
      await SupabaseConfig.client
          .from('journal_entries')
          .delete()
          .eq('id', entryId);
    } catch (e) {
      throw ServerException('Gagal menghapus catatan mood: $e');
    }
  }

  @override
  Future<JournalEntryModel?> getEntryByDate(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().substring(0, 10); // YYYY-MM-DD

      final response = await SupabaseConfig.client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .eq('entry_date', dateStr)
          .maybeSingle();

      if (response == null) return null;
      return JournalEntryModel.fromJson(response);
    } catch (e) {
      throw ServerException('Gagal mengambil catatan mood: $e');
    }
  }
}

