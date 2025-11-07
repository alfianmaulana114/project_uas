import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_achievement.dart';
import '../repositories/reward_repository.dart';

class GetUserAchievementsUsecase {
  final RewardRepository repository;
  GetUserAchievementsUsecase(this.repository);

  Future<Either<Failure, List<UserAchievement>>> call({required String userId}) {
    return repository.getUserAchievements(userId: userId);
  }
}