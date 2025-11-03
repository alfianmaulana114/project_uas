import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_challenge.dart';
import '../repositories/challenge_repository.dart';

/// Use case untuk mendapatkan active challenges user
/// Mengikuti konsep Single Responsibility Principle (SOLID)
/// Setiap use case memiliki satu tanggung jawab
class GetActiveChallengeUsecase {
  /// Instance dari ChallengeRepository
  /// Menggunakan dependency injection untuk loose coupling
  final ChallengeRepository repository;

  /// Constructor untuk GetActiveChallengeUsecase
  /// [repository] adalah instance dari ChallengeRepository
  GetActiveChallengeUsecase(this.repository);

  /// Method untuk execute get active challenges
  /// [params] adalah parameter yang berisi category (opsional)
  /// Mengembalikan Either<Failure, List<UserChallenge>>
  Future<Either<Failure, List<UserChallenge>>> call(GetActiveChallengeParams params) async {
    /// Memanggil repository untuk mendapatkan active challenges
    return await repository.getActiveChallenges(category: params.category);
  }
}

/// Class untuk parameter GetActiveChallengeUsecase
/// Menggunakan class terpisah untuk parameter (bukan Map)
/// Mengikuti konsep type safety
class GetActiveChallengeParams {
  /// Kategori challenge (opsional, null berarti semua kategori)
  final String? category;

  /// Constructor untuk GetActiveChallengeParams
  const GetActiveChallengeParams({
    this.category,
  });
}


