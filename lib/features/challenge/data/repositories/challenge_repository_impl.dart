import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/user_challenge.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../datasources/challenge_remote_datasource.dart';

class ChallengeRepositoryImpl implements ChallengeRepository {
  final ChallengeRemoteDatasource remote;
  ChallengeRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<Challenge>>> getAllChallenges({String? category}) async {
    try {
      final res = await remote.getAllChallenges(category: category);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserChallenge>>> getActiveChallenges({String? category}) async {
    try {
      final res = await remote.getActiveChallenges(category: category);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserChallenge>> startChallenge({
    required String challengeId,
    DateTime? startDate,
    String? bookName,
    String? eventName,
  }) async {
    try {
      final res = await remote.startChallenge(
        challengeId: challengeId,
        startDate: startDate,
        bookName: bookName,
        eventName: eventName,
      );
      return Right(res);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}


