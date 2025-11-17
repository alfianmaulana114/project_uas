import 'package:flutter/foundation.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/entities/daily_checkin_stat.dart';
import '../../domain/usecases/get_user_stats_usecase.dart';
import '../../domain/usecases/get_weekly_checkins_usecase.dart';

class AnalyticsProvider with ChangeNotifier {
  final GetUserStatsUsecase getUserStatsUsecase;
  final GetWeeklyCheckInsUsecase getWeeklyCheckInsUsecase;

  AnalyticsProvider({
    required this.getUserStatsUsecase,
    required this.getWeeklyCheckInsUsecase,
  });

  bool _loading = false;
  UserStats? _stats;
  List<DailyCheckInStat> _weekly = const [];
  String? _error;

  bool get loading => _loading;
  UserStats? get stats => _stats;
  List<DailyCheckInStat> get weekly => _weekly;
  String? get error => _error;

  Future<void> load(String userId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final statsRes = await getUserStatsUsecase(userId: userId);
    statsRes.fold((l) => _error = l.message, (r) => _stats = r);

    final weeklyRes = await getWeeklyCheckInsUsecase(userId: userId);
    weeklyRes.fold((l) => _error = l.message, (r) => _weekly = r);

    _loading = false;
    notifyListeners();
  }
}