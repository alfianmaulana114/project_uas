import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/challenge.dart';
import '../repositories/challenge_repository.dart';

/// Use case untuk mendapatkan semua challenges
/// Mengikuti konsep Single Responsibility Principle (SOLID)
/// Setiap use case memiliki satu tanggung jawab
class GetAllChallengesUsecase {
  /// Instance dari ChallengeRepository
  /// Menggunakan dependency injection untuk loose coupling
  final ChallengeRepository repository;

  /// Constructor untuk GetAllChallengesUsecase
  /// [repository] adalah instance dari ChallengeRepository
  GetAllChallengesUsecase(this.repository);

  /// Method untuk execute get all challenges
  /// [params] adalah parameter yang berisi category (opsional)
  /// Mengembalikan Either<Failure, List<Challenge>>
  Future<Either<Failure, List<Challenge>>> call(GetAllChallengesParams params) async {
    /// Memanggil repository untuk mendapatkan semua challenges
    return await repository.getAllChallenges(category: params.category);
  }
}

/// Class untuk parameter GetAllChallengesUsecase
/// Menggunakan class terpisah untuk parameter (bukan Map)
/// Mengikuti konsep type safety
class GetAllChallengesParams {
  /// Kategori challenge (opsional, null berarti semua kategori)
  final String? category;

  /// Constructor untuk GetAllChallengesParams
  const GetAllChallengesParams({
    this.category,
  });
}


