import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/journal_entry.dart';

/// Repository interface untuk journal
abstract class JournalRepository {
  Future<Either<Failure, List<JournalEntry>>> getAllEntries(String userId);
  Future<Either<Failure, JournalEntry>> createEntry(JournalEntry entry);
  Future<Either<Failure, JournalEntry>> updateEntry(JournalEntry entry);
  Future<Either<Failure, void>> deleteEntry(String entryId);
  Future<Either<Failure, JournalEntry?>> getEntryByDate(String userId, DateTime date);
}

