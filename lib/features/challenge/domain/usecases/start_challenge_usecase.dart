import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_challenge.dart';
import '../repositories/challenge_repository.dart';

class StartChallengeUsecase {
  final ChallengeRepository repository;
  StartChallengeUsecase(this.repository);

  Future<Either<Failure, UserChallenge>> call({
    required String challengeId,
    DateTime? startDate,
    String? bookName,
    String? eventName,
  }) {
    return repository.startChallenge(
      challengeId: challengeId,
      startDate: startDate,
      bookName: bookName,
      eventName: eventName,
    );
  }
}


