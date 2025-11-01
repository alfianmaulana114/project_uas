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
        /// Jika error karena tabel tidak ditemukan (404 atau PGRST205)
        if (e.toString().contains('Could not find the table') ||
            e.toString().contains('PGRST205') ||
            e.toString().contains('404') ||
            (e.toString().contains('relation') && e.toString().contains('does not exist'))) {
          throw AuthException(
            'Tabel users tidak ditemukan di database atau belum ter-expose ke API. '
            'Pastikan:\n'
            '1. Tabel users sudah dibuat di Supabase\n'
            '2. Jalankan script fix_api_exposure.sql untuk grant permissions\n'
            '3. Refresh schema cache di Supabase Dashboard\n'
            '4. Pastikan schema "public" ter-expose di Settings → API',
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
      /// Validasi email format sebelum signup
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw const AuthException('Format email tidak valid');
      }
      
      /// Validasi password minimal 6 karakter
      if (password.length < 6) {
        throw const AuthException('Password minimal 6 karakter');
      }

      /// Melakukan sign up dengan Supabase
      final response = await SupabaseConfig.client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      /// Jika user tidak berhasil dibuat, cek apakah ada error message
      if (response.user == null) {
        /// Cek apakah ada session error atau error message
        if (response.session == null) {
          /// Mungkin email confirmation diaktifkan
          /// Atau ada error yang tidak ter-throw
          throw const AuthException(
            'Gagal membuat user. '
            'Periksa email Anda untuk konfirmasi atau coba lagi.',
          );
        }
        throw const AuthException('Gagal membuat user');
      }

      /// Insert atau update data user ke tabel users (public schema)
      /// Menggunakan id dari auth.users yang baru dibuat
      /// Trigger handle_new_user() mungkin sudah membuat profil, jadi cek dulu
      /// Semua data disimpan langsung ke Supabase (online database)
      try {
        /// Tunggu sebentar untuk memastikan trigger sudah jalan (jika ada)
        await Future.delayed(const Duration(milliseconds: 500));

        /// Coba ambil data user yang sudah ada (dari trigger)
        try {
          final existingUserData = await SupabaseConfig.client
              .from('users')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();

          /// Jika profil sudah ada (dari trigger), update dengan data tambahan
          if (existingUserData != null) {
            /// Update profil dengan data tambahan (full_name, username) jika ada
            final updatedUserData = await SupabaseConfig.client
                .from('users')
                .update({
                  'email': email, // Update email untuk memastikan konsisten
                  'full_name': fullName?.isEmpty == true ? null : fullName,
                  'username': username?.isEmpty == true ? null : username,
                })
                .eq('id', response.user!.id)
                .select()
                .single();

            /// Convert data user ke AuthUserModel
            return AuthUserModel.fromJson(updatedUserData);
          }
        } catch (e) {
          /// Jika error saat get/update, lanjut ke insert
          print('Error getting/updating existing user: $e');
        }

        /// Jika profil belum ada, insert baru
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
            
            /// Jika error karena tabel tidak ditemukan (schema cache issue atau 404)
            if (e.toString().contains('Could not find the table') ||
                e.toString().contains('PGRST205') ||
                e.toString().contains('404') ||
                (e.toString().contains('relation') && e.toString().contains('does not exist'))) {
              retryCount++;
              
              /// Jika sudah retry maksimal, throw error
              if (retryCount >= maxRetries) {
                throw AuthException(
                  'Tabel users tidak ditemukan di database atau belum ter-expose ke API. '
                  'Pastikan:\n'
                  '1. Tabel users sudah dibuat (jalankan setup_users_table.sql)\n'
                  '2. Permissions sudah diberikan (jalankan fix_api_exposure.sql)\n'
                  '3. Schema "public" ter-expose di Settings → API → Exposed schemas\n'
                  '4. Refresh schema cache atau jalankan: NOTIFY pgrst, \'reload schema\';',
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
        
        /// Jika error karena tabel tidak ditemukan (setelah retry) atau 404
        if (e.toString().contains('Could not find the table') ||
            e.toString().contains('PGRST205') ||
            e.toString().contains('404') ||
            (e.toString().contains('relation') && e.toString().contains('does not exist')) ||
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
        /// Jika error karena constraint (misalnya email/username sudah ada)
        if (e.toString().contains('duplicate key') ||
            e.toString().contains('unique constraint') ||
            e.toString().contains('violates unique constraint')) {
          /// Jika duplicate key pada id, berarti profil sudah ada (dari trigger)
          /// Coba ambil data yang sudah ada
          if (e.toString().contains('id') || e.toString().contains('users_pkey')) {
            try {
              final existingUserData = await SupabaseConfig.client
                  .from('users')
                  .select()
                  .eq('id', response.user!.id)
                  .single();
              
              /// Update dengan data tambahan jika perlu
              final updatedUserData = await SupabaseConfig.client
                  .from('users')
                  .update({
                    'email': email,
                    'full_name': fullName?.isEmpty == true ? null : fullName,
                    'username': username?.isEmpty == true ? null : username,
                  })
                  .eq('id', response.user!.id)
                  .select()
                  .single();
              
              return AuthUserModel.fromJson(updatedUserData);
            } catch (_) {
              /// Jika gagal get/update, throw error
              throw const AuthException('Email atau username sudah terdaftar');
            }
          }
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
      /// Log error untuk debugging
      print('SignUp error: $e');
      
      /// Jika terjadi error, convert ke AuthException
      if (e is AuthException) {
        rethrow;
      }
      
      /// Error 400 Bad Request biasanya dari Supabase Auth validation
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('400') || 
          errorString.contains('bad request')) {
        /// Cek error message spesifik
        /// Email sudah terdaftar
        if (errorString.contains('user already registered') ||
            errorString.contains('email already registered') ||
            errorString.contains('already registered')) {
          throw const AuthException('Email sudah terdaftar');
        }
        
        /// Email tidak valid
        if (errorString.contains('invalid email') ||
            errorString.contains('email format')) {
          throw const AuthException('Format email tidak valid');
        }
        
        /// Password terlalu pendek atau tidak valid
        if (errorString.contains('password') && 
            (errorString.contains('too short') || 
             errorString.contains('minimum') ||
             errorString.contains('weak'))) {
          throw const AuthException('Password minimal 6 karakter');
        }
        
        /// Error umum dari Supabase Auth
        if (errorString.contains('signup_disabled') ||
            errorString.contains('signup disabled')) {
          throw const AuthException('Sign up saat ini tidak tersedia');
        }
        
        /// Extract pesan error dari response jika ada
        if (errorString.contains('message')) {
          /// Coba extract pesan dari JSON response
          final match = RegExp(r'message["\s:]+([^"]+)', caseSensitive: false)
              .firstMatch(errorString);
          if (match != null) {
            throw AuthException(match.group(1) ?? 'Gagal melakukan sign up');
          }
        }
        
        throw const AuthException(
          'Gagal melakukan sign up. '
          'Pastikan email valid dan password minimal 6 karakter.',
        );
      }
      
      /// Jika error dari Supabase auth (selain 400)
      if (errorString.contains('user already registered') ||
          errorString.contains('email already registered')) {
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
        /// Jika error karena tabel tidak ditemukan atau 404
        if (e.toString().contains('Could not find the table') ||
            e.toString().contains('PGRST205') ||
            e.toString().contains('404') ||
            (e.toString().contains('relation') && e.toString().contains('does not exist'))) {
          /// Return null karena error ini bisa terjadi saat tabel belum dibuat atau belum ter-expose
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

