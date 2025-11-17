import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/achievement.dart';
import '../entities/user_achievement.dart';

abstract class RewardRepository {
  Future<Either<Failure, List<Achievement>>> getAllAchievements();
  Future<Either<Failure, List<UserAchievement>>> getUserAchievements({required String userId});
  Future<Either<Failure, bool>> awardAchievement({required String userId, required String achievementId});

  // Metrics used to evaluate achievements
  Future<Either<Failure, int>> getSuccessfulCheckinCount({required String userId});
  Future<Either<Failure, int>> getCompletedChallengesCount({required String userId});
  Future<Either<Failure, int>> getCurrentStreak({required String userId});
}