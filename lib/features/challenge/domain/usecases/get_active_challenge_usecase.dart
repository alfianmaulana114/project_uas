import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_challenge.dart';
import '../repositories/challenge_repository.dart';

class GetActiveChallengeUsecase {
  final ChallengeRepository repository;
  GetActiveChallengeUsecase(this.repository);

  Future<Either<Failure, List<UserChallenge>>> call({String? category}) {
    return repository.getActiveChallenges(category: category);
  }
}


