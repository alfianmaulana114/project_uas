import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_stats.dart';
import '../repositories/analytics_repository.dart';

class GetUserStatsUsecase {
  final AnalyticsRepository repository;
  GetUserStatsUsecase(this.repository);

  Future<Either<Failure, UserStats>> call({required String userId}) {
    return repository.getUserStats(userId: userId);
  }
}