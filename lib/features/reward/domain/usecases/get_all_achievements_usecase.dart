import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/achievement.dart';
import '../repositories/reward_repository.dart';

class GetAllAchievementsUsecase {
  final RewardRepository repository;
  GetAllAchievementsUsecase(this.repository);

  Future<Either<Failure, List<Achievement>>> call() {
    return repository.getAllAchievements();
  }
}