import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/reward_repository.dart';

class AwardAchievementUsecase {
  final RewardRepository repository;
  AwardAchievementUsecase(this.repository);

  Future<Either<Failure, bool>> call({required String userId, required String achievementId}) {
    return repository.awardAchievement(userId: userId, achievementId: achievementId);
  }
}