import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/challenge_model.dart';
import '../models/user_challenge_model.dart';

/// Abstract class untuk remote datasource challenge
/// Mengikuti konsep Dependency Inversion Principle (SOLID)
abstract class ChallengeRemoteDatasource {
  /// Method untuk mendapatkan semua challenges
  /// [category] adalah kategori challenge (opsional, null berarti semua kategori)
  /// Mengembalikan List<ChallengeModel> jika berhasil
  /// Throws ServerException jika gagal
  Future<List<ChallengeModel>> getAllChallenges({String? category});

  /// Method untuk mendapatkan active challenges user
  /// [category] adalah kategori challenge (opsional, null berarti semua kategori)
  /// Mengembalikan List<UserChallengeModel> jika berhasil
  /// Throws ServerException jika gagal
  Future<List<UserChallengeModel>> getActiveChallenges({String? category});

  /// Method untuk memulai challenge baru
  /// [challengeId] adalah ID challenge yang akan dimulai
  /// [startDate] adalah tanggal mulai challenge (opsional, default adalah hari ini)
  /// [bookName] adalah nama buku untuk challenge membaca_buku (opsional)
  /// [eventName] adalah nama event untuk challenge bersosialisasi (opsional)
  /// Mengembalikan UserChallengeModel jika berhasil
  /// Throws AuthException jika user sudah punya challenge aktif di kategori yang sama
  /// Throws ServerException jika gagal
  Future<UserChallengeModel> startChallenge({
    required String challengeId,
    DateTime? startDate,
    String? bookName,
    String? eventName,
  });
}

/// Implementation dari ChallengeRemoteDatasource menggunakan Supabase
/// Mengikuti konsep Single Responsibility Principle (SOLID)
/// SEMUA DATA DISIMPAN ONLINE DI SUPABASE - TIDAK ADA DATABASE LOKAL
/// Semua operasi langsung ke Supabase database online
class ChallengeRemoteDatasourceImpl implements ChallengeRemoteDatasource {
  /// Constructor untuk ChallengeRemoteDatasourceImpl
  ChallengeRemoteDatasourceImpl();

  @override
  Future<List<ChallengeModel>> getAllChallenges({String? category}) async {
    try {
      // Jika category null, jangan kirim parameter apapun (gunakan DEFAULT NULL di function)
      // Jika category ada, kirim sebagai string - Supabase akan auto-cast ke enum
      final params = <String, dynamic>{};
      if (category != null && category.isNotEmpty) {
        params['p_category'] = category;
      }
      
      final res = await SupabaseConfig.client.rpc(
        'rpc_get_all_challenges',
        params: params.isEmpty ? null : params,
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
      // Jika category null, jangan kirim parameter apapun (gunakan DEFAULT NULL di function)
      // Jika category ada, kirim sebagai string - Supabase akan auto-cast ke enum
      final params = <String, dynamic>{};
      if (category != null && category.isNotEmpty) {
        params['p_category'] = category;
      }
      
      final res = await SupabaseConfig.client.rpc(
        'rpc_get_active_user_challenges',
        params: params.isEmpty ? null : params,
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


