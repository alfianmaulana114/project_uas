import 'package:flutter/foundation.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/user_challenge.dart';
import '../../domain/usecases/get_all_challenges_usecase.dart';
import '../../domain/usecases/get_active_challenge_usecase.dart';
import '../../domain/usecases/start_challenge_usecase.dart';
import '../../domain/usecases/check_in_usecase.dart';
import '../../domain/entities/check_in_result.dart';

class ChallengeProvider extends ChangeNotifier {
  final GetAllChallengesUsecase getAllChallengesUsecase;
  final GetActiveChallengeUsecase getActiveChallengeUsecase;
  final StartChallengeUsecase startChallengeUsecase;
  final CheckInUsecase checkInUsecase;

  ChallengeProvider({
    required this.getAllChallengesUsecase,
    required this.getActiveChallengeUsecase,
    required this.startChallengeUsecase,
    required this.checkInUsecase,
  });

  final List<Challenge> _challenges = [];
  final List<UserChallenge> _active = [];
  String? _error;
  bool _loading = false;
  String? _selectedCategory; // null = all

  List<Challenge> get challenges => List.unmodifiable(_challenges);
  List<UserChallenge> get activeChallenges => List.unmodifiable(_active);
  String? get error => _error;
  bool get isLoading => _loading;
  String? get selectedCategory => _selectedCategory;

  Future<void> load({String? category}) async {
    _loading = true;
    _error = null;
    _selectedCategory = category;
    notifyListeners();

    final res = await getAllChallengesUsecase(category: category);
    res.fold((l) {
      _error = l.message;
      _challenges.clear();
    }, (r) {
      _challenges
        ..clear()
        ..addAll(r);
    });

    final act = await getActiveChallengeUsecase(category: category);
    act.fold((l) {
      _error = l.message;
      _active.clear();
    }, (r) {
      _active
        ..clear()
        ..addAll(r);
    });

    _loading = false;
    notifyListeners();
  }

  Future<bool> start({
    required String challengeId,
    String? bookName,
    String? eventName,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final res = await startChallengeUsecase(
      challengeId: challengeId,
      bookName: bookName,
      eventName: eventName,
    );

    final ok = res.fold((l) {
      _error = l.message;
      return false;
    }, (r) {
      _active.add(r);
      return true;
    });

    _loading = false;
    notifyListeners();
    return ok;
  }

  /// Daily check-in: mark success/failed and update state
  Future<CheckInResult?> checkIn({
    required String userChallengeId,
    required bool isSuccess,
    DateTime? checkInDate,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    // Validation: must exist in active list
    final idx = _active.indexWhere((uc) => uc.id == userChallengeId);
    if (idx < 0) {
      _error = 'Tidak ada challenge aktif';
      _loading = false;
      notifyListeners();
      return null;
    }

    final res = await checkInUsecase(
      userChallengeId: userChallengeId,
      isSuccess: isSuccess,
      checkInDate: checkInDate,
    );

    final result = res.fold<CheckInResult?>(
      (l) {
        _error = l.message;
        return null;
      },
      (r) => r,
    );

    // Apply state updates
    if (result != null) {
      // Replace updated challenge in active list or remove if completed
      final updated = _active[idx];
      final updatedChallenge = UserChallenge(
        id: updated.id,
        userId: updated.userId,
        challengeId: updated.challengeId,
        category: updated.category,
        startDate: updated.startDate,
        endDate: updated.endDate,
        status: result.status,
        currentDay: result.currentDay,
        successDays: result.successDays,
        pointsEarned: updated.pointsEarned + result.pointsAwarded,
        bookName: updated.bookName,
        eventName: updated.eventName,
        completedAt: result.challengeCompleted ? DateTime.now() : updated.completedAt,
        createdAt: updated.createdAt,
      );

      if (result.status == 'completed' || result.challengeCompleted) {
        _active.removeAt(idx);
      } else {
        _active[idx] = updatedChallenge;
      }
    }

    _loading = false;
    notifyListeners();
    return result;
  }
}


