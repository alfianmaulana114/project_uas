import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/user_challenge.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../datasources/challenge_remote_datasource.dart';

/// Implementation dari ChallengeRepository
/// Mengikuti konsep Clean Architecture - Data Layer
/// Menggunakan dependency injection untuk ChallengeRemoteDatasource
/// Convert exceptions ke failures (Domain Layer pattern)
/// 
/// PENTING: Tidak ada local storage atau cache mechanism
/// Semua data langsung ke Supabase (online database)
/// State challenge hanya disimpan di memory (Provider), tidak persist
class ChallengeRepositoryImpl implements ChallengeRepository {
  /// Instance dari ChallengeRemoteDatasource
  /// Menggunakan dependency injection untuk loose coupling
  /// Hanya menggunakan remote datasource (Supabase), tidak ada local datasource
  final ChallengeRemoteDatasource remoteDatasource;

  /// Constructor untuk ChallengeRepositoryImpl
  /// [remoteDatasource] adalah instance dari ChallengeRemoteDatasource
  ChallengeRepositoryImpl(this.remoteDatasource);

  /// Method untuk mendapatkan semua challenges
  /// Convert exception ke failure sesuai dengan Clean Architecture
  @override
  Future<Either<Failure, List<Challenge>>> getAllChallenges({String? category}) async {
    try {
      /// Memanggil remote datasource untuk mendapatkan semua challenges
      final result = await remoteDatasource.getAllChallenges(category: category);

      /// Jika berhasil, return Right dengan List<Challenge>
      return Right(result);
    } on ServerException catch (e) {
      /// Jika terjadi ServerException, convert ke ServerFailure
      return Left(ServerFailure(e.message));
    } catch (e) {
      /// Jika terjadi error lain, convert ke ServerFailure
      return Left(ServerFailure('Gagal mengambil challenges: ${e.toString()}'));
    }
  }

  /// Method untuk mendapatkan active challenges user
  /// Convert exception ke failure sesuai dengan Clean Architecture
  @override
  Future<Either<Failure, List<UserChallenge>>> getActiveChallenges({String? category}) async {
    try {
      /// Memanggil remote datasource untuk mendapatkan active challenges
      final result = await remoteDatasource.getActiveChallenges(category: category);

      /// Jika berhasil, return Right dengan List<UserChallenge>
      return Right(result);
    } on ServerException catch (e) {
      /// Jika terjadi ServerException, convert ke ServerFailure
      return Left(ServerFailure(e.message));
    } catch (e) {
      /// Jika terjadi error lain, convert ke ServerFailure
      return Left(ServerFailure('Gagal mengambil active challenges: ${e.toString()}'));
    }
  }

  /// Method untuk memulai challenge baru
  /// Convert exception ke failure sesuai dengan Clean Architecture
  @override
  Future<Either<Failure, UserChallenge>> startChallenge({
    required String challengeId,
    DateTime? startDate,
    String? bookName,
    String? eventName,
  }) async {
    try {
      /// Memanggil remote datasource untuk memulai challenge
      final result = await remoteDatasource.startChallenge(
        challengeId: challengeId,
        startDate: startDate,
        bookName: bookName,
        eventName: eventName,
      );

      /// Jika berhasil, return Right dengan UserChallenge
      return Right(result);
    } on AuthException catch (e) {
      /// Jika terjadi AuthException, convert ke AuthFailure
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      /// Jika terjadi ServerException, convert ke ServerFailure
      return Left(ServerFailure(e.message));
    } catch (e) {
      /// Jika terjadi error lain, convert ke ServerFailure
      return Left(ServerFailure('Gagal memulai challenge: ${e.toString()}'));
    }
  }
}


