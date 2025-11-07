import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_stats.dart';
import '../entities/daily_checkin_stat.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, UserStats>> getUserStats({required String userId});
  Future<Either<Failure, List<DailyCheckInStat>>> getWeeklyCheckIns({required String userId});
}