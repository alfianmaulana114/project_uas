import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/challenge.dart';
import '../entities/user_challenge.dart';
import '../entities/check_in_result.dart';

/// Abstract repository untuk challenge
/// Mengikuti Dependency Inversion Principle (SOLID)
/// Menggunakan Either dari package dartz untuk error handling
abstract class ChallengeRepository {
  /// Method untuk mendapatkan semua challenges
  /// Mengembalikan Either<Failure, List<Challenge>>
  /// Left = Failure, Right = List<Challenge>
  /// [category] adalah kategori challenge (opsional, null berarti semua kategori)
  Future<Either<Failure, List<Challenge>>> getAllChallenges({String? category});

  /// Method untuk mendapatkan active challenges user
  /// Mengembalikan Either<Failure, List<UserChallenge>>
  /// Left = Failure, Right = List<UserChallenge>
  /// [category] adalah kategori challenge (opsional, null berarti semua kategori)
  Future<Either<Failure, List<UserChallenge>>> getActiveChallenges({String? category});

  /// Method untuk memulai challenge baru
  /// Mengembalikan Either<Failure, UserChallenge>
  /// Left = Failure, Right = UserChallenge
  /// [challengeId] adalah ID challenge yang akan dimulai
  /// [startDate] adalah tanggal mulai challenge (opsional, default adalah hari ini)
  /// [bookName] adalah nama buku untuk challenge membaca_buku (opsional)
  /// [eventName] adalah nama event untuk challenge bersosialisasi (opsional)
  Future<Either<Failure, UserChallenge>> startChallenge({
    required String challengeId,
    DateTime? startDate,
    String? bookName,
    String? eventName,
  });

  /// Mark daily check-in for a user challenge
  /// Returns CheckInResult containing updated challenge and user stats
  Future<Either<Failure, CheckInResult>> checkIn({
    required String userChallengeId,
    required bool isSuccess,
    DateTime? checkInDate,
  });
}


