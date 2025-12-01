import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart' as app_exceptions;
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_achievement.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/reward_item.dart';
import '../../domain/entities/reward_redemption.dart';
import '../../domain/repositories/reward_repository.dart';
import '../datasources/reward_remote_datasource.dart';

class RewardRepositoryImpl implements RewardRepository {
  final RewardRemoteDatasource remote;
  RewardRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<Achievement>>> getAllAchievements() async {
    try {
      final data = await remote.getAllAchievements();
      return Right(data.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserAchievement>>> getUserAchievements({required String userId}) async {
    try {
      final data = await remote.getUserAchievements(userId);
      return Right(data.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> awardAchievement({required String userId, required String achievementId}) async {
    try {
      // Points are handled by remote using achievement row
      // Fetch achievement to get points
      final all = await remote.getAllAchievements();
      final ach = all.firstWhere((a) => a.id == achievementId);
      final ok = await remote.awardAchievement(userId, achievementId, ach.pointsReward);
      return Right(ok);
    } catch (e) {
      if (e is app_exceptions.AuthException) return Left(AuthFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getSuccessfulCheckinCount({required String userId}) async {
    try {
      final n = await remote.getSuccessfulCheckinCount(userId);
      return Right(n);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getCompletedChallengesCount({required String userId}) async {
    try {
      final n = await remote.getCompletedChallengesCount(userId);
      return Right(n);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getCurrentStreak({required String userId}) async {
    try {
      final n = await remote.getCurrentStreak(userId);
      return Right(n);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard({
    String sortBy = 'points',
    int limit = 100,
  }) async {
    try {
      final data = await remote.getLeaderboard(sortBy: sortBy, limit: limit);
      return Right(data.map((e) => e.toEntity()).toList());
    } catch (e) {
      if (e is app_exceptions.AuthException) return Left(AuthFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RewardItem>>> getAllRewardItems({String? category}) async {
    try {
      final data = await remote.getAllRewardItems(category: category);
      return Right(data.map((e) => e.toEntity()).toList());
    } catch (e) {
      if (e is app_exceptions.AuthException) return Left(AuthFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> redeemReward({required String rewardItemId}) async {
    try {
      final data = await remote.redeemReward(rewardItemId);
      return Right(data);
    } catch (e) {
      if (e is app_exceptions.AuthException) return Left(AuthFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RewardRedemption>>> getUserRedemptions({int limit = 50}) async {
    try {
      final data = await remote.getUserRedemptions(limit: limit);
      return Right(data.map((e) => e.toEntity()).toList());
    } catch (e) {
      if (e is app_exceptions.AuthException) return Left(AuthFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addPoints({required int points}) async {
    try {
      final data = await remote.addPoints(points);
      return Right(data);
    } catch (e) {
      if (e is app_exceptions.AuthException) return Left(AuthFailure(e.message));
      return Left(ServerFailure(e.toString()));
    }
  }
}