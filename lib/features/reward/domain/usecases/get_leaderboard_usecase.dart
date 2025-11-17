import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/leaderboard_entry.dart';
import '../repositories/reward_repository.dart';

/// Use case untuk mendapatkan leaderboard
class GetLeaderboardUsecase {
  final RewardRepository repository;

  GetLeaderboardUsecase(this.repository);

  /// Get leaderboard entries
  /// [sortBy] bisa: 'points', 'streak', 'challenges', 'checkins'
  /// [limit] jumlah entry yang diambil (default 100)
  Future<Either<Failure, List<LeaderboardEntry>>> call({
    String sortBy = 'points',
    int limit = 100,
  }) async {
    return await repository.getLeaderboard(sortBy: sortBy, limit: limit);
  }
}

