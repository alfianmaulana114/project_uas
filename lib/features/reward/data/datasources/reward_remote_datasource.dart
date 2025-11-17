import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/achievement_model.dart';
import '../models/user_achievement_model.dart';
import '../models/leaderboard_entry_model.dart';

abstract class RewardRemoteDatasource {
  Future<List<AchievementModel>> getAllAchievements();
  Future<List<UserAchievementModel>> getUserAchievements(String userId);
  Future<bool> awardAchievement(String userId, String achievementId, int pointsReward);

  Future<int> getSuccessfulCheckinCount(String userId);
  Future<int> getCompletedChallengesCount(String userId);
  Future<int> getCurrentStreak(String userId);
  
  /// Get leaderboard entries
  /// [sortBy] bisa: 'points', 'streak', 'challenges', 'checkins'
  /// [limit] jumlah entry yang diambil (default 100)
  Future<List<LeaderboardEntryModel>> getLeaderboard({
    String sortBy = 'points',
    int limit = 100,
  });
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

  @override
  Future<List<LeaderboardEntryModel>> getLeaderboard({
    String sortBy = 'points',
    int limit = 100,
  }) async {
    // Query untuk mendapatkan leaderboard dengan aggregasi data
    // Kita perlu join users dengan data dari user_challenges dan checkins
    
    // Step 1: Get all users dengan stats dasar
    final usersRes = await _client
        .from('users')
        .select('id, username, full_name, avatar_url, total_points, current_streak, longest_streak')
        .order('total_points', ascending: false)
        .limit(limit);
    
    final users = (usersRes as List).cast<Map<String, dynamic>>();
    
    // Step 2: Get completed challenges count per user
    final completedChallengesRes = await _client
        .from('user_challenges')
        .select('user_id')
        .eq('status', 'completed');
    
    final completedMap = <String, int>{};
    for (final row in (completedChallengesRes as List).cast<Map<String, dynamic>>()) {
      final userId = row['user_id'] as String;
      completedMap[userId] = (completedMap[userId] ?? 0) + 1;
    }
    
    // Step 3: Get total successful checkins per user
    final checkinsRes = await _client
        .from('checkins')
        .select('user_challenge_id, is_success')
        .eq('is_success', true);
    
    // Get user_challenge_ids untuk mapping
    final userChallengeIds = <String, String>{};
    final userChallengesRes = await _client
        .from('user_challenges')
        .select('id, user_id');
    
    for (final row in (userChallengesRes as List).cast<Map<String, dynamic>>()) {
      userChallengeIds[row['id'] as String] = row['user_id'] as String;
    }
    
    final checkinsMap = <String, int>{};
    for (final row in (checkinsRes as List).cast<Map<String, dynamic>>()) {
      final challengeId = row['user_challenge_id'] as String;
      final userId = userChallengeIds[challengeId];
      if (userId != null) {
        checkinsMap[userId] = (checkinsMap[userId] ?? 0) + 1;
      }
    }
    
    // Step 4: Combine data dan sort
    final entries = <LeaderboardEntryModel>[];
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      final userId = user['id'] as String;
      
      entries.add(LeaderboardEntryModel(
        userId: userId,
        username: user['username'] as String?,
        fullName: user['full_name'] as String?,
        avatarUrl: user['avatar_url'] as String?,
        totalPoints: (user['total_points'] ?? 0) as int,
        currentStreak: (user['current_streak'] ?? 0) as int,
        longestStreak: (user['longest_streak'] ?? 0) as int,
        completedChallenges: completedMap[userId] ?? 0,
        totalCheckins: checkinsMap[userId] ?? 0,
        rank: i + 1,
      ));
    }
    
    // Sort berdasarkan sortBy
    switch (sortBy) {
      case 'streak':
        entries.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
        break;
      case 'challenges':
        entries.sort((a, b) => b.completedChallenges.compareTo(a.completedChallenges));
        break;
      case 'checkins':
        entries.sort((a, b) => b.totalCheckins.compareTo(a.totalCheckins));
        break;
      case 'points':
      default:
        entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
        break;
    }
    
    // Update rank setelah sort
    for (int i = 0; i < entries.length; i++) {
      entries[i] = LeaderboardEntryModel(
        userId: entries[i].userId,
        username: entries[i].username,
        fullName: entries[i].fullName,
        avatarUrl: entries[i].avatarUrl,
        totalPoints: entries[i].totalPoints,
        currentStreak: entries[i].currentStreak,
        longestStreak: entries[i].longestStreak,
        completedChallenges: entries[i].completedChallenges,
        totalCheckins: entries[i].totalCheckins,
        rank: i + 1,
      );
    }
    
    return entries;
  }
}