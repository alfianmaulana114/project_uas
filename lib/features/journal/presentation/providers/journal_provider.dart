import 'package:flutter/foundation.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/usecases/create_entry_usecase.dart';
import '../../domain/usecases/get_all_entries_usecase.dart';
import '../../domain/usecases/delete_entry_usecase.dart';

/// Provider untuk mengelola state journal entries
class JournalProvider extends ChangeNotifier {
  final CreateEntryUsecase createEntryUsecase;
  final GetAllEntriesUsecase getAllEntriesUsecase;
  final DeleteEntryUsecase deleteEntryUsecase;

  JournalProvider({
    required this.createEntryUsecase,
    required this.getAllEntriesUsecase,
    required this.deleteEntryUsecase,
  });

  final List<JournalEntry> _entries = [];
  bool _loading = false;
  String? _error;

  List<JournalEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _loading;
  String? get error => _error;

  /// Load semua entries dari Supabase
  Future<void> loadEntries(String userId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await getAllEntriesUsecase(userId);

    result.fold(
      (failure) {
        _error = failure.message;
        _entries.clear();
      },
      (entries) {
        _entries
          ..clear()
          ..addAll(entries);
        _error = null;
      },
    );

    _loading = false;
    notifyListeners();
  }

  /// Buat entry baru
  Future<bool> createEntry(JournalEntry entry) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await createEntryUsecase(entry);

    final success = result.fold(
      (failure) {
        _error = failure.message;
        return false;
      },
      (createdEntry) {
        _entries.insert(0, createdEntry);
        _error = null;
        return true;
      },
    );

    _loading = false;
    notifyListeners();
    return success;
  }

  /// Hapus entry
  Future<bool> deleteEntry(String entryId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await deleteEntryUsecase(entryId);

    final success = result.fold(
      (failure) {
        _error = failure.message;
        return false;
      },
      (_) {
        _entries.removeWhere((e) => e.id == entryId);
        _error = null;
        return true;
      },
    );

    _loading = false;
    notifyListeners();
    return success;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

