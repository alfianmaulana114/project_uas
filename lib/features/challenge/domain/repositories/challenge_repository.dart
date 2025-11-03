import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/challenge.dart';
import '../entities/user_challenge.dart';

abstract class ChallengeRepository {
  Future<Either<Failure, List<Challenge>>> getAllChallenges({String? category});

  Future<Either<Failure, List<UserChallenge>>> getActiveChallenges({String? category});

  Future<Either<Failure, UserChallenge>> startChallenge({
    required String challengeId,
    DateTime? startDate,
    String? bookName,
    String? eventName,
  });
}


