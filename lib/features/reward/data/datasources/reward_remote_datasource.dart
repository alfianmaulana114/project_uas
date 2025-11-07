import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/achievement_model.dart';
import '../models/user_achievement_model.dart';

abstract class RewardRemoteDatasource {
  Future<List<AchievementModel>> getAllAchievements();
  Future<List<UserAchievementModel>> getUserAchievements(String userId);
  Future<bool> awardAchievement(String userId, String achievementId, int pointsReward);

  Future<int> getSuccessfulCheckinCount(String userId);
  Future<int> getCompletedChallengesCount(String userId);
  Future<int> getCurrentStreak(String userId);
}

class RewardRemoteDatasourceImpl implements RewardRemoteDatasource {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<List<AchievementModel>> getAllAchievements() async {
    final res = await _client.from('achievements').select();
    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map((e) => AchievementModel.fromJson(e)).toList();
  }

  @override
  Future<List<UserAchievementModel>> getUserAchievements(String userId) async {
    final res = await _client
        .from('user_achievements')
        .select()
        .eq('user_id', userId);
    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map((e) => UserAchievementModel.fromJson(e)).toList();
  }

  @override
  Future<bool> awardAchievement(String userId, String achievementId, int pointsReward) async {
    try {
      await _client.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
      });
    } catch (e) {
      final m = e.toString().toLowerCase();
      if (m.contains('duplicate') || m.contains('unique')) {
        // Already awarded
      } else {
        rethrow;
      }
    }
    // Update user points
    final uid = userId;
    final user = await _client.from('users').select('total_points').eq('id', uid).maybeSingle();
    final current = (user?['total_points'] ?? 0) as int;
    await _client.from('users').update({'total_points': current + pointsReward}).eq('id', uid);
    return true;
  }

  @override
  Future<int> getSuccessfulCheckinCount(String userId) async {
    // Get all user's challenge ids
    final ucs = await _client.from('user_challenges').select('id').eq('user_id', userId);
    final ids = (ucs as List).map((e) => e['id'] as String).toList();
    if (ids.isEmpty) return 0;
    final res = await _client
        .from('checkins')
        .select('id, user_challenge_id, is_success')
        .eq('is_success', true);
    final list = (res as List).cast<Map<String, dynamic>>();
    final set = ids.toSet();
    return list.where((row) => set.contains(row['user_challenge_id'] as String)).length;
  }

  @override
  Future<int> getCompletedChallengesCount(String userId) async {
    final res = await _client
        .from('user_challenges')
        .select('id')
        .eq('user_id', userId)
        .eq('status', 'completed');
    return (res as List).length;
  }

  @override
  Future<int> getCurrentStreak(String userId) async {
    final res = await _client.from('users').select('current_streak').eq('id', userId).maybeSingle();
    return (res?['current_streak'] ?? 0) as int;
  }
}