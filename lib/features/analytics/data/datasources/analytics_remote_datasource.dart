import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/daily_checkin_stat.dart';
import '../models/user_stats_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<UserStatsModel> getUserStats(String userId);
  Future<List<DailyCheckInStat>> getWeeklyCheckIns(String userId);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  SupabaseClient get client => SupabaseConfig.client;

  @override
  Future<UserStatsModel> getUserStats(String userId) async {
    final res = await client.from('user_stats').select().eq('user_id', userId).limit(1);
    if (res.isNotEmpty) {
      return UserStatsModel.fromMap(res.first);
    }
    return const UserStatsModel(
      userId: '',
      totalPoints: 0,
      currentStreak: 0,
      longestStreak: 0,
      completedChallenges: 0,
      activitiesCompleted: 0,
      badgesEarned: 0,
    );
  }

  @override
  Future<List<DailyCheckInStat>> getWeeklyCheckIns(String userId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    // Fetch check-ins in last 7 days for this user
    // Query melalui user_challenges untuk mendapatkan checkins milik user
    final userChallengesResponse = await client
        .from('user_challenges')
        .select('id')
        .eq('user_id', userId);
    
    final userChallengeIds = (userChallengesResponse as List)
        .map((uc) => (uc as Map<String, dynamic>)['id'] as String)
        .toList();
    
    if (userChallengeIds.isEmpty) {
      // Return empty stats jika tidak ada challenge
      return _buildEmptyStats(start);
    }
    
    final checkins = await client
        .from('checkins')
        .select()
        .inFilter('user_challenge_id', userChallengeIds)
        .gte('checkin_date', start.toIso8601String().substring(0, 10));

    // Build daily stats
    final byDay = <String, Map<String, int>>{}; // yyyy-MM-dd -> {success, failed, minutes}
    for (int i = 0; i < 7; i++) {
      final d = DateTime(start.year, start.month, start.day).add(Duration(days: i));
      byDay[_fmtDate(d)] = {'success': 0, 'failed': 0, 'minutes': 0};
    }

    for (final raw in checkins) {
      final m = Map<String, dynamic>.from(raw);
      final checkinDateStr = m['checkin_date']?.toString();
      if (checkinDateStr == null) continue;
      final checkinDate = DateTime.tryParse(checkinDateStr);
      if (checkinDate == null) continue;
      final key = _fmtDate(checkinDate);
      if (!byDay.containsKey(key)) continue;
      
      final isSuccess = (m['is_success'] == true) || (m['status']?.toString() == 'success');
      final durationMinutes = (m['duration_minutes'] as num?)?.toInt() ?? 0;
      final bucket = byDay[key]!;
      
      if (isSuccess) {
        bucket['success'] = (bucket['success'] ?? 0) + 1;
        bucket['minutes'] = (bucket['minutes'] ?? 0) + durationMinutes;
      } else {
        bucket['failed'] = (bucket['failed'] ?? 0) + 1;
      }
    }
  
    return byDay.entries.map((e) {
      final dateParts = e.key.split('-');
      final d = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      final bucket = e.value;
      return DailyCheckInStat(
        date: d,
        successCount: bucket['success'] ?? 0,
        failedCount: bucket['failed'] ?? 0,
        totalMinutes: bucket['minutes'] ?? 0,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  String _fmtDate(DateTime d) {
    final dt = DateTime(d.year, d.month, d.day);
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
  
  List<DailyCheckInStat> _buildEmptyStats(DateTime start) {
    final stats = <DailyCheckInStat>[];
    for (int i = 0; i < 7; i++) {
      final d = DateTime(start.year, start.month, start.day).add(Duration(days: i));
      stats.add(DailyCheckInStat(
        date: d,
        successCount: 0,
        failedCount: 0,
        totalMinutes: 0,
      ));
    }
    return stats;
  }
}