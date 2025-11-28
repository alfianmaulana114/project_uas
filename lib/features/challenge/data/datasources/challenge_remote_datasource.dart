import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/challenge_model.dart';
import '../models/user_challenge_model.dart';
import '../models/check_in_result_model.dart';

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
  Future<CheckInResultModel> checkIn({
    required String userChallengeId,
    required bool isSuccess,
    DateTime? checkInDate,
    int durationMinutes = 0,
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

  @override
  Future<CheckInResultModel> checkIn({
    required String userChallengeId,
    required bool isSuccess,
    DateTime? checkInDate,
    int durationMinutes = 0,
  }) async {
    try {
      final res = await SupabaseConfig.client.rpc(
        'rpc_check_in',
        params: {
          'p_user_challenge_id': userChallengeId,
          'p_is_success': isSuccess,
          if (checkInDate != null) 'p_checkin_date': checkInDate.toIso8601String().substring(0, 10),
          'p_duration_minutes': durationMinutes,
        },
      );
      final data = (res as Map<String, dynamic>);
      return CheckInResultModel.fromJson(data);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      // Detect duplicate check-in errors from RPC (Indonesian and English variants)
      if (msg.contains('sudah') && msg.contains('check-in')) {
        throw AuthException('Sudah check-in hari ini');
      }
      if (msg.contains('already') && msg.contains('check-in')) {
        throw AuthException('Sudah check-in hari ini');
      }
      if (msg.contains('no active challenge') || msg.contains('tidak ada challenge aktif')) {
        throw AuthException('Tidak ada challenge aktif untuk check-in');
      }
      // Fallback: jika rpc_check_in belum terpasang di Supabase (PGRST202), gunakan rpc_log_daily_progress
      if (msg.contains('pgrst202') || msg.contains('could not find the function public.rpc_check_in') || msg.contains('code: 42703')) {
        try {
          final res2 = await SupabaseConfig.client.rpc(
            'rpc_log_daily_progress',
            params: {
              'p_user_challenge_id': userChallengeId,
              'p_success': isSuccess,
            },
          );
          final uc = (res2 as Map<String, dynamic>);
          final fallback = <String, dynamic>{
            'user_challenge': uc,
            'is_success': isSuccess,
            'already_checked_in_today': false,
            'challenge_completed': (uc['status'] == 'completed'),
            'points_awarded': 0,
            'current_streak': 0,
            'longest_streak': 0,
            'total_points': 0,
            'status': uc['status'],
            'current_day': uc['current_day'],
            'success_days': uc['success_days'],
          };
          return CheckInResultModel.fromJson(fallback);
        } catch (e2) {
          final m2 = e2.toString().toLowerCase();
          // Jika fungsi lama masih pakai EXTRACT yang salah tipe (code 42883)
          if (m2.contains('extract(unknown, integer)') || m2.contains('code: 42883')) {
            throw ServerException(
              'Server belum di-update: fungsi rpc_log_daily_progress error (EXTRACT). '
              'Silakan jalankan ulang SQL di Supabase: setup_challenges.sql lalu NOTIFY pgrst,\'reload schema\'. '
              'Alternatif lebih baik: pasang rpc_check_in dari setup_checkin_rpc.sql.'
            );
          }
          throw ServerException('Gagal fallback ke RPC lama: $e2');
        }
      }
      throw ServerException('Gagal melakukan check-in: $e');
    }
  }
}


