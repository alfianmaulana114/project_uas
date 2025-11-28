import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/check_in_result.dart';
import '../repositories/challenge_repository.dart';

class CheckInUsecase {
  final ChallengeRepository repository;
  CheckInUsecase(this.repository);

  Future<Either<Failure, CheckInResult>> call({
    required String userChallengeId,
    required bool isSuccess,
    DateTime? checkInDate,
    int durationMinutes = 0,
  }) {
    return repository.checkIn(
      userChallengeId: userChallengeId,
      isSuccess: isSuccess,
      checkInDate: checkInDate,
      durationMinutes: durationMinutes,
    );
  }
}