import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_achievement.dart';
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
      if (e is AuthException) return Left(AuthFailure(e.message));
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
}