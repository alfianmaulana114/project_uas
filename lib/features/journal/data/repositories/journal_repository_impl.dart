import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/journal_remote_datasource.dart';
import '../models/journal_entry_model.dart';

/// Implementation dari JournalRepository
class JournalRepositoryImpl implements JournalRepository {
  final JournalRemoteDatasource remoteDatasource;

  JournalRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<JournalEntry>>> getAllEntries(String userId) async {
    try {
      final entries = await remoteDatasource.getAllEntries(userId);
      return Right(entries);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal mengambil catatan mood: $e'));
    }
  }

  @override
  Future<Either<Failure, JournalEntry>> createEntry(JournalEntry entry) async {
    try {
      final model = JournalEntryModel(
        id: entry.id,
        userId: entry.userId,
        mood: entry.mood,
        note: entry.note,
        createdAt: entry.createdAt,
        updatedAt: entry.updatedAt,
      );
      final created = await remoteDatasource.createEntry(model);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal menyimpan catatan mood: $e'));
    }
  }

  @override
  Future<Either<Failure, JournalEntry>> updateEntry(JournalEntry entry) async {
    try {
      final model = JournalEntryModel(
        id: entry.id,
        userId: entry.userId,
        mood: entry.mood,
        note: entry.note,
        createdAt: entry.createdAt,
        updatedAt: entry.updatedAt,
      );
      final updated = await remoteDatasource.updateEntry(model);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal memperbarui catatan mood: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(String entryId) async {
    try {
      await remoteDatasource.deleteEntry(entryId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal menghapus catatan mood: $e'));
    }
  }

  @override
  Future<Either<Failure, JournalEntry?>> getEntryByDate(String userId, DateTime date) async {
    try {
      final entry = await remoteDatasource.getEntryByDate(userId, date);
      return Right(entry);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal mengambil catatan mood: $e'));
    }
  }
}

