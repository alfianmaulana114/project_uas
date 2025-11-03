import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_challenge.dart';
import '../repositories/challenge_repository.dart';

/// Use case untuk memulai challenge baru
/// Mengikuti konsep Single Responsibility Principle (SOLID)
/// Setiap use case memiliki satu tanggung jawab
class StartChallengeUsecase {
  /// Instance dari ChallengeRepository
  /// Menggunakan dependency injection untuk loose coupling
  final ChallengeRepository repository;

  /// Constructor untuk StartChallengeUsecase
  /// [repository] adalah instance dari ChallengeRepository
  StartChallengeUsecase(this.repository);

  /// Method untuk execute start challenge
  /// [params] adalah parameter yang berisi challengeId, startDate, bookName, dan eventName
  /// Mengembalikan Either<Failure, UserChallenge>
  Future<Either<Failure, UserChallenge>> call(StartChallengeParams params) async {
    /// Validasi challengeId sebelum memulai challenge
    if (params.challengeId.isEmpty) {
      return Left(AuthFailure('Challenge ID tidak boleh kosong'));
    }

    /// Memanggil repository untuk memulai challenge
    return await repository.startChallenge(
      challengeId: params.challengeId,
      startDate: params.startDate,
      bookName: params.bookName,
      eventName: params.eventName,
    );
  }
}

/// Class untuk parameter StartChallengeUsecase
/// Menggunakan class terpisah untuk parameter (bukan Map)
/// Mengikuti konsep type safety
class StartChallengeParams {
  /// ID challenge yang akan dimulai
  final String challengeId;

  /// Tanggal mulai challenge (opsional, default adalah hari ini)
  final DateTime? startDate;

  /// Nama buku (untuk challenge membaca_buku, opsional)
  final String? bookName;

  /// Nama event (untuk challenge bersosialisasi, opsional)
  final String? eventName;

  /// Constructor untuk StartChallengeParams
  const StartChallengeParams({
    required this.challengeId,
    this.startDate,
    this.bookName,
    this.eventName,
  });
}


