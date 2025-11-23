import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/achievement.dart';
import '../repositories/reward_repository.dart';

class CheckAchievementsUsecase {
  final RewardRepository repository;
  CheckAchievementsUsecase(this.repository);

  /// Evaluate and award achievements based on current stats and event trigger.
  /// Returns list of newly awarded achievements.
  Future<Either<Failure, List<Achievement>>> call({
    required String userId,
    String? trigger, // e.g., 'check_in', 'complete_challenge', 'activity_complete', 'streak'
  }) async {
    // Fetch definitions and already-owned achievements
    final allRes = await repository.getAllAchievements();
    final ownedRes = await repository.getUserAchievements(userId: userId);
    return allRes.fold((l) => Left(l), (all) async {
      return ownedRes.fold((l) => Left(l), (owned) async {
        final ownedIds = owned.map((e) => e.achievementId).toSet();

        // Metrics
        final checkinsRes = await repository.getSuccessfulCheckinCount(userId: userId);
        final completedRes = await repository.getCompletedChallengesCount(userId: userId);
        final streakRes = await repository.getCurrentStreak(userId: userId);

        return checkinsRes.fold((l) => Left(l), (checkins) async {
          return completedRes.fold((l) => Left(l), (completed) async {
            return streakRes.fold((l) => Left(l), (streak) async {
              final newlyAwarded = <Achievement>[];

              bool meets(Achievement a) {
                switch (a.requirementType) {
                  case 'first_checkin':
                    return checkins >= 1;
                  case 'check_in_days':
                    return checkins >= a.requirementValue;
                  case 'complete_challenge':
                    return completed >= a.requirementValue;
                  case 'streak_days':
                    return streak >= a.requirementValue;
                  default:
                    return false;
                }
              }

              for (final a in all) {
                if (ownedIds.contains(a.id)) continue; // skip already owned
                if (meets(a)) {
                  // Award and collect
                  final awardRes = await repository.awardAchievement(userId: userId, achievementId: a.id);
                  awardRes.fold((_) {}, (ok) {
                    if (ok) newlyAwarded.add(a);
                  });
                }
              }

              return Right(newlyAwarded);
            });
          });
        });
      });
    });
  }
}