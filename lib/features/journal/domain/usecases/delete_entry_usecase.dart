import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/journal_repository.dart';

class DeleteEntryUsecase {
  final JournalRepository repository;

  DeleteEntryUsecase(this.repository);

  Future<Either<Failure, void>> call(String entryId) {
    return repository.deleteEntry(entryId);
  }
}

