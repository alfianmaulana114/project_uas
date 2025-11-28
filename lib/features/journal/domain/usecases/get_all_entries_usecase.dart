import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

class GetAllEntriesUsecase {
  final JournalRepository repository;

  GetAllEntriesUsecase(this.repository);

  Future<Either<Failure, List<JournalEntry>>> call(String userId) {
    return repository.getAllEntries(userId);
  }
}

