import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:project_uas/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:project_uas/features/challenge/domain/entities/challenge.dart';
import 'package:project_uas/features/challenge/domain/entities/user_challenge.dart';
import 'package:project_uas/features/challenge/domain/entities/check_in_result.dart';
import 'package:project_uas/features/challenge/domain/usecases/get_all_challenges_usecase.dart';
import 'package:project_uas/features/challenge/domain/usecases/get_active_challenge_usecase.dart';
import 'package:project_uas/features/challenge/domain/usecases/start_challenge_usecase.dart';
import 'package:project_uas/features/challenge/domain/usecases/check_in_usecase.dart';
import 'package:project_uas/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:project_uas/core/errors/failures.dart';

class _DummyRepo implements ChallengeRepository {
  @override
  Future<Either<Failure, CheckInResult>> checkIn({required String userChallengeId, required bool isSuccess, DateTime? checkInDate, int durationMinutes = 0}) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Challenge>>> getAllChallenges({String? category}) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<UserChallenge>>> getActiveChallenges({String? category}) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserChallenge>> startChallenge({required String challengeId, DateTime? startDate, String? bookName, String? eventName}) async {
    throw UnimplementedError();
  }
}

class _StubGetAll extends GetAllChallengesUsecase {
  _StubGetAll() : super(_DummyRepo());
  @override
  Future<Either<Failure, List<Challenge>>> call(GetAllChallengesParams params) async => Right([]);
}

class _StubGetActive extends GetActiveChallengeUsecase {
  _StubGetActive() : super(_DummyRepo());
  @override
  Future<Either<Failure, List<UserChallenge>>> call(GetActiveChallengeParams params) async => Right([]);
}

class _StubStart extends StartChallengeUsecase {
  final UserChallenge userChallenge;
  _StubStart(this.userChallenge) : super(_DummyRepo());
  @override
  Future<Either<Failure, UserChallenge>> call(StartChallengeParams params) async => Right(userChallenge);
}

class _StubCheckIn extends CheckInUsecase {
  final CheckInResult result;
  final Failure? error;
  _StubCheckIn({required this.result, this.error}) : super(_DummyRepo());
  @override
  Future<Either<Failure, CheckInResult>> call({
    required String userChallengeId,
    required bool isSuccess,
    DateTime? checkInDate,
    int durationMinutes = 0,
  }) async {
    if (error != null) return Left(error!);
    return Right(result);
  }
}

void main() {
  UserChallenge makeChallenge({int day = 0, int success = 0}) {
    return UserChallenge(
      id: 'uc1',
      userId: 'u1',
      challengeId: 'c1',
      category: 'olahraga',
      startDate: DateTime(2025, 1, 1),
      endDate: null,
      status: 'active',
      currentDay: day,
      successDays: success,
      pointsEarned: 0,
      bookName: null,
      eventName: null,
      completedAt: null,
      createdAt: DateTime(2025, 1, 1),
    );
  }

  CheckInResult makeResult({
    required bool isSuccess,
    int currentDay = 1,
    int successDays = 1,
    int currentStreak = 1,
    int longestStreak = 1,
    int totalPoints = 10,
    bool alreadyCheckedInToday = false,
    bool challengeCompleted = false,
    int pointsAwarded = 0,
  }) {
    return CheckInResult(
      userChallengeId: 'uc1',
      isSuccess: isSuccess,
      alreadyCheckedInToday: alreadyCheckedInToday,
      challengeCompleted: challengeCompleted,
      pointsAwarded: pointsAwarded,
      status: challengeCompleted ? 'completed' : 'active',
      currentDay: currentDay,
      successDays: successDays,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalPoints: totalPoints,
    );
  }

  test('Test check-in success', () async {
    final provider = ChallengeProvider(
      getAllChallengesUsecase: _StubGetAll(),
      getActiveChallengeUsecase: _StubGetActive(),
      startChallengeUsecase: _StubStart(makeChallenge(day: 0, success: 0)),
      checkInUsecase: _StubCheckIn(result: makeResult(isSuccess: true, currentDay: 1, successDays: 1)),
    );
    await provider.start(challengeId: 'c1');
    final res = await provider.checkIn(userChallengeId: 'uc1', isSuccess: true);
    expect(res, isNotNull);
    expect(res!.isSuccess, true);
  });

  test('Test check-in failed', () async {
    final provider = ChallengeProvider(
      getAllChallengesUsecase: _StubGetAll(),
      getActiveChallengeUsecase: _StubGetActive(),
      startChallengeUsecase: _StubStart(makeChallenge(day: 0, success: 0)),
      checkInUsecase: _StubCheckIn(result: makeResult(isSuccess: false, currentDay: 1, successDays: 0, currentStreak: 0)),
    );
    await provider.start(challengeId: 'c1');
    final res = await provider.checkIn(userChallengeId: 'uc1', isSuccess: false);
    expect(res, isNotNull);
    expect(res!.isSuccess, false);
    expect(res.currentStreak, 0);
  });

  test('Test tidak bisa check-in 2x di hari yang sama', () async {
    final fail = AuthFailure('Anda sudah check-in hari ini');
    final provider = ChallengeProvider(
      getAllChallengesUsecase: _StubGetAll(),
      getActiveChallengeUsecase: _StubGetActive(),
      startChallengeUsecase: _StubStart(makeChallenge(day: 1, success: 1)),
      checkInUsecase: _StubCheckIn(result: makeResult(isSuccess: true), error: fail),
    );
    await provider.start(challengeId: 'c1');
    final res = await provider.checkIn(userChallengeId: 'uc1', isSuccess: true);
    expect(res, isNull);
    expect(provider.error, contains('check-in'));
  });

  test('Test streak naik saat success', () async {
    final provider = ChallengeProvider(
      getAllChallengesUsecase: _StubGetAll(),
      getActiveChallengeUsecase: _StubGetActive(),
      startChallengeUsecase: _StubStart(makeChallenge(day: 2, success: 1)),
      checkInUsecase: _StubCheckIn(result: makeResult(isSuccess: true, currentDay: 3, successDays: 2, currentStreak: 3)),
    );
    await provider.start(challengeId: 'c1');
    final res = await provider.checkIn(userChallengeId: 'uc1', isSuccess: true);
    expect(res, isNotNull);
    expect(res!.currentStreak, 3);
  });

  test('Test streak reset saat failed', () async {
    final provider = ChallengeProvider(
      getAllChallengesUsecase: _StubGetAll(),
      getActiveChallengeUsecase: _StubGetActive(),
      startChallengeUsecase: _StubStart(makeChallenge(day: 2, success: 2)),
      checkInUsecase: _StubCheckIn(result: makeResult(isSuccess: false, currentDay: 3, successDays: 2, currentStreak: 0)),
    );
    await provider.start(challengeId: 'c1');
    final res = await provider.checkIn(userChallengeId: 'uc1', isSuccess: false);
    expect(res, isNotNull);
    expect(res!.currentStreak, 0);
  });

  test('Test challenge completion (setelah 7 hari)', () async {
    final provider = ChallengeProvider(
      getAllChallengesUsecase: _StubGetAll(),
      getActiveChallengeUsecase: _StubGetActive(),
      startChallengeUsecase: _StubStart(makeChallenge(day: 7, success: 6)),
      checkInUsecase: _StubCheckIn(
        result: makeResult(
          isSuccess: true,
          currentDay: 8,
          successDays: 7,
          challengeCompleted: true,
          pointsAwarded: 100,
          totalPoints: 100,
        ),
      ),
    );
    await provider.start(challengeId: 'c1');
    final res = await provider.checkIn(userChallengeId: 'uc1', isSuccess: true);
    expect(res, isNotNull);
    expect(res!.challengeCompleted, true);
    expect(res.pointsAwarded, 100);
  });
}
