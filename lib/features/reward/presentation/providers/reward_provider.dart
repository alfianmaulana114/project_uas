import 'package:flutter/foundation.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_achievement.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/reward_item.dart';
import '../../domain/entities/reward_redemption.dart';
import '../../domain/usecases/get_all_achievements_usecase.dart';
import '../../domain/usecases/get_user_achievements_usecase.dart';
import '../../domain/usecases/check_achievements_usecase.dart';
import '../../domain/usecases/get_leaderboard_usecase.dart';
import '../../domain/usecases/get_all_reward_items_usecase.dart';
import '../../domain/usecases/redeem_reward_usecase.dart';
import '../../domain/usecases/get_user_redemptions_usecase.dart';
import '../../domain/usecases/add_points_usecase.dart';

class RewardProvider extends ChangeNotifier {
  final GetAllAchievementsUsecase getAllAchievementsUsecase;
  final GetUserAchievementsUsecase getUserAchievementsUsecase;
  final CheckAchievementsUsecase checkAchievementsUsecase;
  final GetLeaderboardUsecase getLeaderboardUsecase;
  final GetAllRewardItemsUsecase getAllRewardItemsUsecase;
  final RedeemRewardUsecase redeemRewardUsecase;
  final GetUserRedemptionsUsecase getUserRedemptionsUsecase;
  final AddPointsUsecase addPointsUsecase;
  final AuthProvider authProvider;

  RewardProvider({
    required this.getAllAchievementsUsecase,
    required this.getUserAchievementsUsecase,
    required this.checkAchievementsUsecase,
    required this.getLeaderboardUsecase,
    required this.getAllRewardItemsUsecase,
    required this.redeemRewardUsecase,
    required this.getUserRedemptionsUsecase,
    required this.addPointsUsecase,
    required this.authProvider,
  });

  final List<Achievement> _achievements = [];
  final List<UserAchievement> _owned = [];
  final List<LeaderboardEntry> _leaderboard = [];
  final List<RewardItem> _rewardItems = [];
  final List<RewardRedemption> _redemptions = [];
  bool _loading = false;
  bool _leaderboardLoading = false;
  bool _rewardItemsLoading = false;
  bool _redeeming = false;
  String? _error;
  String? _leaderboardError;
  String? _rewardItemsError;
  String _leaderboardSortBy = 'points';

  List<Achievement> get achievements => List.unmodifiable(_achievements);
  List<UserAchievement> get owned => List.unmodifiable(_owned);
  List<LeaderboardEntry> get leaderboard => List.unmodifiable(_leaderboard);
  List<RewardItem> get rewardItems => List.unmodifiable(_rewardItems);
  List<RewardRedemption> get redemptions => List.unmodifiable(_redemptions);
  bool get isLoading => _loading;
  bool get isLeaderboardLoading => _leaderboardLoading;
  bool get isRewardItemsLoading => _rewardItemsLoading;
  bool get isRedeeming => _redeeming;
  String? get error => _error;
  String? get leaderboardError => _leaderboardError;
  String? get rewardItemsError => _rewardItemsError;
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

  /// Load reward items
  Future<void> loadRewardItems({String? category}) async {
    _rewardItemsLoading = true;
    _rewardItemsError = null;
    notifyListeners();

    final res = await getAllRewardItemsUsecase(category: category);
    res.fold(
      (failure) {
        _rewardItemsError = failure.message;
        _rewardItems.clear();
      },
      (items) {
        _rewardItems
          ..clear()
          ..addAll(items);
      },
    );

    _rewardItemsLoading = false;
    notifyListeners();
  }

  /// Redeem reward (menukar poin dengan reward)
  Future<Map<String, dynamic>?> redeemReward(String rewardItemId) async {
    _redeeming = true;
    _error = null;
    notifyListeners();

    final res = await redeemRewardUsecase(rewardItemId: rewardItemId);
    final result = res.fold<Map<String, dynamic>?>(
      (failure) {
        _error = failure.message;
        return null;
      },
      (data) => data,
    );

    if (result != null) {
      // Reload reward items untuk update stok
      await loadRewardItems();
      // Reload user data untuk update poin
      await authProvider.getCurrentUser();
    }

    _redeeming = false;
    notifyListeners();
    return result;
  }

  /// Load user redemptions (history penukaran)
  Future<void> loadRedemptions({int limit = 50}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final res = await getUserRedemptionsUsecase(limit: limit);
    res.fold(
      (failure) {
        _error = failure.message;
        _redemptions.clear();
      },
      (redemptions) {
        _redemptions
          ..clear()
          ..addAll(redemptions);
      },
    );

    _loading = false;
    notifyListeners();
  }

  /// Add points to user (untuk testing atau bonus)
  Future<Map<String, dynamic>?> addPoints(int points) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final res = await addPointsUsecase(points: points);
    final result = res.fold<Map<String, dynamic>?>(
      (failure) {
        _error = failure.message;
        return null;
      },
      (data) => data,
    );

    if (result != null) {
      // Reload user data untuk update poin
      await authProvider.getCurrentUser();
    }

    _loading = false;
    notifyListeners();
    return result;
  }
}