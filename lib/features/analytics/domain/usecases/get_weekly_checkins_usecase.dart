import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/daily_checkin_stat.dart';
import '../repositories/analytics_repository.dart';

class GetWeeklyCheckInsUsecase {
  final AnalyticsRepository repository;
  GetWeeklyCheckInsUsecase(this.repository);

  Future<Either<Failure, List<DailyCheckInStat>>> call({required String userId}) {
    return repository.getWeeklyCheckIns(userId: userId);
  }
}