import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/entities/daily_checkin_stat.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remote;
  AnalyticsRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, UserStats>> getUserStats({required String userId}) async {
    try {
      final res = await remote.getUserStats(userId);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyCheckInStat>>> getWeeklyCheckIns({required String userId}) async {
    try {
      final res = await remote.getWeeklyCheckIns(userId);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}