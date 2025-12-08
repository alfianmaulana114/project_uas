import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/challenge_repository.dart';

class HasCheckedInTodayUsecase {
  final ChallengeRepository repository;
  HasCheckedInTodayUsecase(this.repository);

  Future<Either<Failure, bool>> call(String userChallengeId) {
    return repository.hasCheckedInToday(userChallengeId);
  }
}
