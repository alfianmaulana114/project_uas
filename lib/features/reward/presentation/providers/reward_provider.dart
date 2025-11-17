import 'package:flutter/foundation.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_achievement.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/usecases/get_all_achievements_usecase.dart';
import '../../domain/usecases/get_user_achievements_usecase.dart';
import '../../domain/usecases/check_achievements_usecase.dart';
import '../../domain/usecases/get_leaderboard_usecase.dart';

class RewardProvider extends ChangeNotifier {
  final GetAllAchievementsUsecase getAllAchievementsUsecase;
  final GetUserAchievementsUsecase getUserAchievementsUsecase;
  final CheckAchievementsUsecase checkAchievementsUsecase;
  final GetLeaderboardUsecase getLeaderboardUsecase;
  final AuthProvider authProvider;

  RewardProvider({
    required this.getAllAchievementsUsecase,
    required this.getUserAchievementsUsecase,
    required this.checkAchievementsUsecase,
    required this.getLeaderboardUsecase,
    required this.authProvider,
  });

  final List<Achievement> _achievements = [];
  final List<UserAchievement> _owned = [];
  final List<LeaderboardEntry> _leaderboard = [];
  bool _loading = false;
  bool _leaderboardLoading = false;
  String? _error;
  String? _leaderboardError;
  String _leaderboardSortBy = 'points';

  List<Achievement> get achievements => List.unmodifiable(_achievements);
  List<UserAchievement> get owned => List.unmodifiable(_owned);
  List<LeaderboardEntry> get leaderboard => List.unmodifiable(_leaderboard);
  bool get isLoading => _loading;
  bool get isLeaderboardLoading => _leaderboardLoading;
  String? get error => _error;
  String? get leaderboardError => _leaderboardError;
  String get leaderboardSortBy => _leaderboardSortBy;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final userId = authProvider.currentUser?.id;
    if (userId == null) {
      _error = 'User belum login';
      _loading = false;
      notifyListeners();
      return;
    }
    final aRes = await getAllAchievementsUsecase();
    aRes.fold((l) {
      _error = l.message;
    }, (r) {
      _achievements
        ..clear()
        ..addAll(r);
    });
    final uRes = await getUserAchievementsUsecase(userId: userId);
    uRes.fold((l) {
      _error = l.message;
    }, (r) {
      _owned
        ..clear()
        ..addAll(r);
    });
    _loading = false;
    notifyListeners();
  }

  /// Check achievements after an event (check-in, complete challenge, activity)
  /// Returns newly unlocked achievements
  Future<List<Achievement>> checkAfterEvent({String? trigger}) async {
    final userId = authProvider.currentUser?.id;
    if (userId == null) return [];
    final res = await checkAchievementsUsecase(userId: userId, trigger: trigger);
    return res.fold((l) {
      _error = l.message;
      return [];
    }, (awarded) async {
      // Reload owned list after awarding
      await load();
      // Update points in AuthProvider by refetching from DB is optional; current RPC updates points
      return awarded;
    });
  }

  /// Load leaderboard
  Future<void> loadLeaderboard({String? sortBy, int limit = 100}) async {
    _leaderboardLoading = true;
    _leaderboardError = null;
    _leaderboardSortBy = sortBy ?? _leaderboardSortBy;
    notifyListeners();

    final res = await getLeaderboardUsecase(
      sortBy: _leaderboardSortBy,
      limit: limit,
    );

    res.fold(
      (failure) {
        _leaderboardError = failure.message;
        _leaderboard.clear();
      },
      (entries) {
        _leaderboard
          ..clear()
          ..addAll(entries);
      },
    );

    _leaderboardLoading = false;
    notifyListeners();
  }
}