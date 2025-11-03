import 'package:flutter/foundation.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/user_challenge.dart';
import '../../domain/usecases/get_all_challenges_usecase.dart';
import '../../domain/usecases/get_active_challenge_usecase.dart';
import '../../domain/usecases/start_challenge_usecase.dart';

class ChallengeProvider extends ChangeNotifier {
  final GetAllChallengesUsecase getAllChallengesUsecase;
  final GetActiveChallengeUsecase getActiveChallengeUsecase;
  final StartChallengeUsecase startChallengeUsecase;

  ChallengeProvider({
    required this.getAllChallengesUsecase,
    required this.getActiveChallengeUsecase,
    required this.startChallengeUsecase,
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
}


