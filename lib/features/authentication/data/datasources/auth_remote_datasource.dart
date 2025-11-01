import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_user_model.dart';

/// Abstract class untuk remote datasource authentication
/// Mengikuti konsep Dependency Inversion Principle (SOLID)
abstract class AuthRemoteDatasource {
  /// Method untuk sign in user dengan email dan password
  /// [email] adalah email user
  /// [password] adalah password user
  /// Mengembalikan AuthUserModel jika berhasil
  /// Throws AuthException jika gagal
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  });

  /// Method untuk sign up user baru
  /// [email] adalah email user
  /// [password] adalah password user
  /// [fullName] adalah nama lengkap user (opsional)
  /// [username] adalah username user (opsional)
  /// Mengembalikan AuthUserModel jika berhasil
  /// Throws AuthException jika gagal
  Future<AuthUserModel> signUp({
    required String email,
    required String password,
    String? fullName,
    String? username,
  });

  /// Method untuk sign out user
  /// Throws AuthException jika gagal
  Future<void> signOut();

  /// Method untuk mendapatkan user yang sedang login
  /// Mengembalikan AuthUserModel? jika ada user yang login
  /// Mengembalikan null jika tidak ada user yang login
  /// Throws AuthException jika terjadi error
  Future<AuthUserModel?> getCurrentUser();
}

/// Implementation dari AuthRemoteDatasource menggunakan Supabase
/// Mengikuti konsep Single Responsibility Principle (SOLID)
/// SEMUA DATA DISIMPAN ONLINE DI SUPABASE - TIDAK ADA DATABASE LOKAL
/// Semua operasi langsung ke Supabase database online
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  /// Constructor untuk AuthRemoteDatasourceImpl
  AuthRemoteDatasourceImpl();

  /// Method untuk sign in user dengan email dan password
  /// Menggunakan Supabase auth.signInWithPassword
  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      /// Melakukan sign in dengan Supabase
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      /// Jika user tidak ada, throw exception
      if (response.user == null) {
        throw const AuthException('User tidak ditemukan');
      }

      /// Mengambil data user dari tabel users di Supabase (online database)
      /// Tidak ada cache lokal, langsung fetch dari server
      try {
        final userData = await SupabaseConfig.client
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        /// Convert data user ke AuthUserModel
        return AuthUserModel.fromJson(userData);
      } catch (e) {
        /// Jika error karena tabel tidak ditemukan
        if (e.toString().contains('Could not find the table') ||
            e.toString().contains('PGRST205')) {
          throw AuthException(
            'Tabel users tidak ditemukan di database. '
            'Pastikan tabel users sudah dibuat di Supabase.',
          );
        }
        /// Jika user tidak ditemukan di tabel users (tapi ada di auth)
        if (e.toString().contains('No rows returned')) {
          /// Buat profil user otomatis jika belum ada
          try {
            final newUserData = await SupabaseConfig.client
                .from('users')
                .insert({
                  'id': response.user!.id,
                  'email': email,
                })
                .select()
                .single();
            return AuthUserModel.fromJson(newUserData);
          } catch (_) {
            throw AuthException(
              'Profil user tidak ditemukan. Silakan hubungi administrator.',
            );
          }
        }
        rethrow;
      }
    } catch (e) {
      /// Jika terjadi error, convert ke AuthException
      if (e is AuthException) {
        rethrow;
      }
      /// Jika error karena kredensial salah
      if (e.toString().contains('Invalid login credentials') ||
          e.toString().contains('invalid_credentials')) {
        throw const AuthException('Email atau password salah');
      }
      throw AuthException('Gagal melakukan sign in: ${e.toString()}');
    }
  }

  /// Method untuk sign up user baru
  /// Menggunakan Supabase auth.signUp dan insert ke tabel users
  @override
  Future<AuthUserModel> signUp({
    required String email,
    required String password,
    String? fullName,
    String? username,
  }) async {
    try {
      /// Melakukan sign up dengan Supabase
      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
      );

      /// Jika user tidak berhasil dibuat, throw exception
      if (response.user == null) {
        throw const AuthException('Gagal membuat user');
      }

      /// Insert data user ke tabel users (public schema)
      /// Menggunakan id dari auth.users yang baru dibuat
      /// Semua data disimpan langsung ke Supabase (online database)
      try {
        /// Tunggu sebentar untuk memastikan auth user sudah terbuat
        await Future.delayed(const Duration(milliseconds: 500));

        /// Coba insert dengan retry logic (untuk handle schema cache refresh)
        int retryCount = 0;
        const maxRetries = 3;
        Exception? lastError;

        while (retryCount < maxRetries) {
          try {
            final userData = await SupabaseConfig.client
                .from('users')
                .insert({
                  'id': response.user!.id, // ID dari auth.users
                  'email': email,
                  'full_name': fullName?.isEmpty == true ? null : fullName,
                  'username': username?.isEmpty == true ? null : username,
                })
                .select()
                .single();

            /// Convert data user ke AuthUserModel
            return AuthUserModel.fromJson(userData);
          } catch (e) {
            lastError = e is Exception ? e : Exception(e.toString());
            
            /// Jika error karena tabel tidak ditemukan (schema cache issue)
            if (e.toString().contains('Could not find the table') ||
                e.toString().contains('PGRST205')) {
              retryCount++;
              
              /// Jika sudah retry maksimal, throw error
              if (retryCount >= maxRetries) {
                throw AuthException(
                  'Tabel users tidak ditemukan di database. '
                  'Silakan refresh schema cache di Supabase Dashboard (Settings → API → Refresh Schema Cache), '
                  'atau pastikan tabel users sudah dibuat dengan benar.',
                );
              }
              
              /// Tunggu sebelum retry (agar schema cache bisa refresh)
              await Future.delayed(Duration(milliseconds: 1000 * retryCount));
              continue;
            }
            
            /// Jika bukan error schema cache, langsung throw
            rethrow;
          }
        }

        /// Jika semua retry gagal
        throw lastError ?? Exception('Unknown error');
      } catch (e) {
        /// Log error untuk debugging
        print('Error inserting user: $e');
        
        /// Jika error karena tabel tidak ditemukan (setelah retry)
        if (e.toString().contains('Could not find the table') ||
            e.toString().contains('PGRST205') ||
            (e is AuthException && e.message.contains('Tabel users tidak ditemukan'))) {
          rethrow; // Sudah di-handle di atas
        }
        /// Jika error karena RLS policy (permission denied)
        if (e.toString().contains('new row violates row-level security') ||
            e.toString().contains('permission denied') ||
            e.toString().contains('RLS') ||
            e.toString().contains('policy')) {
          throw AuthException(
            'Gagal menyimpan data user. '
            'Pastikan RLS Policy sudah dikonfigurasi dengan benar di Supabase. '
            'Error: ${e.toString()}',
          );
        }
        /// Jika error karena constraint (misalnya email sudah ada)
        if (e.toString().contains('duplicate key') ||
            e.toString().contains('unique constraint') ||
            e.toString().contains('violates unique constraint')) {
          throw const AuthException('Email atau username sudah terdaftar');
        }
        /// Jika error foreign key constraint
        if (e.toString().contains('foreign key') ||
            e.toString().contains('references')) {
          throw AuthException(
            'Gagal menyimpan data user. '
            'Pastikan kolom id di tabel users sudah dikonfigurasi dengan benar. '
            'Error: ${e.toString()}',
          );
        }
        /// Re-throw error lain dengan pesan yang lebih jelas
        throw AuthException(
          'Gagal menyimpan data user ke database: ${e.toString()}',
        );
      }
    } catch (e) {
      /// Jika terjadi error, convert ke AuthException
      if (e is AuthException) {
        rethrow;
      }
      /// Jika error dari Supabase auth
      if (e.toString().contains('User already registered') ||
          e.toString().contains('Email already registered')) {
        throw const AuthException('Email sudah terdaftar');
      }
      throw AuthException('Gagal melakukan sign up: ${e.toString()}');
    }
  }

  /// Method untuk sign out user
  /// Menggunakan Supabase auth.signOut
  @override
  Future<void> signOut() async {
    try {
      /// Melakukan sign out dengan Supabase
      await SupabaseConfig.client.auth.signOut();
    } catch (e) {
      /// Jika terjadi error, convert ke AuthException
      throw AuthException('Gagal melakukan sign out: ${e.toString()}');
    }
  }

  /// Method untuk mendapatkan user yang sedang login
  /// Menggunakan Supabase auth.currentUser
  @override
  Future<AuthUserModel?> getCurrentUser() async {
    try {
      /// Mendapatkan current user dari Supabase
      final currentUser = SupabaseConfig.client.auth.currentUser;

      /// Jika tidak ada user yang login, return null
      if (currentUser == null) {
        return null;
      }

      /// Mengambil data user dari tabel users di Supabase (online database)
      /// Tidak ada cache lokal, langsung fetch dari server
      try {
        final userData = await SupabaseConfig.client
            .from('users')
            .select()
            .eq('id', currentUser.id)
            .single();

        /// Convert data user ke AuthUserModel
        return AuthUserModel.fromJson(userData);
      } catch (e) {
        /// Jika error karena tabel tidak ditemukan
        if (e.toString().contains('Could not find the table') ||
            e.toString().contains('PGRST205')) {
          /// Return null karena error ini bisa terjadi saat tabel belum dibuat
          return null;
        }
        /// Jika user tidak ditemukan di tabel users, return null
        /// Bukan error karena bisa jadi user belum punya profil
        return null;
      }
    } catch (e) {
      /// Jika terjadi error, return null (bukan throw exception)
      /// Karena getCurrentUser bisa dipanggil saat user belum login
      return null;
    }
  }
}

