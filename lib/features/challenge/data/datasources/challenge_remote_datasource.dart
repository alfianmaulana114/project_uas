import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/challenge_model.dart';
import '../models/user_challenge_model.dart';

abstract class ChallengeRemoteDatasource {
  Future<List<ChallengeModel>> getAllChallenges({String? category});
  Future<List<UserChallengeModel>> getActiveChallenges({String? category});
  Future<UserChallengeModel> startChallenge({
    required String challengeId,
    DateTime? startDate,
    String? bookName,
    String? eventName,
  });
}

class ChallengeRemoteDatasourceImpl implements ChallengeRemoteDatasource {
  ChallengeRemoteDatasourceImpl();

  @override
  Future<List<ChallengeModel>> getAllChallenges({String? category}) async {
    try {
      final res = await SupabaseConfig.client.rpc(
        'rpc_get_all_challenges',
        params: {
          if (category != null) 'p_category': category,
        },
      );
      final data = (res as List).cast<Map<String, dynamic>>();
      return data.map((e) => ChallengeModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException('Gagal mengambil challenges: $e');
    }
  }

  @override
  Future<List<UserChallengeModel>> getActiveChallenges({String? category}) async {
    try {
      final res = await SupabaseConfig.client.rpc(
        'rpc_get_active_user_challenges',
        params: {
          if (category != null) 'p_category': category,
        },
      );
      final data = (res as List).cast<Map<String, dynamic>>();
      return data.map((e) => UserChallengeModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException('Gagal mengambil active challenges: $e');
    }
  }

  @override
  Future<UserChallengeModel> startChallenge({
    required String challengeId,
    DateTime? startDate,
    String? bookName,
    String? eventName,
  }) async {
    try {
      final res = await SupabaseConfig.client.rpc(
        'rpc_start_challenge',
        params: {
          'p_challenge_id': challengeId,
          if (startDate != null) 'p_start_date': startDate.toIso8601String().substring(0, 10),
          'p_book_name': bookName,
          'p_event_name': eventName,
        },
      );
      final data = (res as Map<String, dynamic>);
      return UserChallengeModel.fromJson(data);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Anda sudah memiliki challenge aktif')) {
        throw AuthException('Anda sudah memiliki challenge aktif pada kategori ini');
      }
      throw ServerException('Gagal memulai challenge: $e');
    }
  }
}


