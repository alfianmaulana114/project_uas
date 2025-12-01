import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/achievement.dart';
import '../entities/user_achievement.dart';
import '../entities/leaderboard_entry.dart';
import '../entities/reward_item.dart';
import '../entities/reward_redemption.dart';

abstract class RewardRepository {
  Future<Either<Failure, List<Achievement>>> getAllAchievements();
  Future<Either<Failure, List<UserAchievement>>> getUserAchievements({required String userId});
  Future<Either<Failure, bool>> awardAchievement({required String userId, required String achievementId});

  // Metrics used to evaluate achievements
  Future<Either<Failure, int>> getSuccessfulCheckinCount({required String userId});
  Future<Either<Failure, int>> getCompletedChallengesCount({required String userId});
  Future<Either<Failure, int>> getCurrentStreak({required String userId});
  
  // Leaderboard
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard({
    String sortBy = 'points',
    int limit = 100,
  });

  // Reward items and redemption
  Future<Either<Failure, List<RewardItem>>> getAllRewardItems({String? category});
  Future<Either<Failure, Map<String, dynamic>>> redeemReward({required String rewardItemId});
  Future<Either<Failure, List<RewardRedemption>>> getUserRedemptions({int limit = 50});
  Future<Either<Failure, Map<String, dynamic>>> addPoints({required int points});
}