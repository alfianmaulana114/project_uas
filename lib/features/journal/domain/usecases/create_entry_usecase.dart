import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

class CreateEntryUsecase {
  final JournalRepository repository;

  CreateEntryUsecase(this.repository);

  Future<Either<Failure, JournalEntry>> call(JournalEntry entry) {
    return repository.createEntry(entry);
  }
}

