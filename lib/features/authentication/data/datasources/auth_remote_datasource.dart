import 'dart:io';
import 'dart:typed_data';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sfb hide AuthException, AuthUser;

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
  
  /// Method untuk update user
  /// [user] adalah user yang akan diupdate
  /// Mengembalikan AuthUserModel jika berhasil
  /// Throws AuthException jika gagal
  Future<AuthUserModel> updateUser(AuthUserModel user);
  
  /// Method untuk update credentials (email dan password)
  /// [email] adalah email baru (opsional)
  /// [password] adalah password baru (opsional)
  /// Mengembalikan AuthUserModel jika berhasil
  /// Throws AuthException jika gagal
  Future<AuthUserModel> updateCredentials({String? email, String? password});

  /// Method untuk mendapatkan user yang sedang login
  /// Mengembalikan AuthUserModel? jika ada user yang login
  /// Mengembalikan null jika tidak ada user yang login
  /// Throws AuthException jika terjadi error
  Future<AuthUserModel?> getCurrentUser();

  /// Method untuk upload avatar ke Supabase Storage
  /// [userId] adalah ID user
  /// [imagePath] adalah path file gambar yang akan diupload
  /// Mengembalikan URL avatar yang sudah diupload
  /// Throws AuthException jika gagal
  Future<String> uploadAvatar({
    required String userId,
    required String imagePath,
  });

  /// Method untuk upload avatar ke Supabase Storage dengan bytes
  /// [userId] adalah ID user
  /// [imageBytes] adalah bytes dari gambar yang akan diupload
  /// Mengembalikan URL avatar yang sudah diupload
  /// Throws AuthException jika gagal
  Future<String> uploadAvatarBytes({
    required String userId,
    required Uint8List imageBytes,
  });
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
          final existingList = await SupabaseConfig.client
              .from('users')
              .select()
              .eq('id', response.user!.id);
          final existingUserData = existingList.isNotEmpty
              ? existingList.first
              : null;

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
          /// Update dengan data tambahan jika perlu
          if (e.toString().contains('id') || e.toString().contains('users_pkey')) {
            try {
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

  @override
  Future<AuthUserModel> updateUser(AuthUserModel user) async {
    try {
      // Hanya update field yang bisa diubah user (email, full_name, username, dan avatar_url)
      // Jangan update stats (total_points, current_streak, longest_streak) karena itu dihitung otomatis
      final updateData = <String, dynamic>{};
      updateData['email'] = user.email;
      if (user.fullName != null) {
        updateData['full_name'] = user.fullName;
      } else {
        updateData['full_name'] = null;
      }
      if (user.username != null) {
        updateData['username'] = user.username;
      } else {
        updateData['username'] = null;
      }
      if (user.avatarUrl != null) {
        updateData['avatar_url'] = user.avatarUrl;
      } else {
        updateData['avatar_url'] = null;
      }
      
      // Update ke Supabase
      final response = await SupabaseConfig.client
          .from('users')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      // Return user yang sudah diupdate dari Supabase (dengan data terbaru)
      return AuthUserModel.fromJson(response);
    } catch (e) {
      // Handle error spesifik
      if (e.toString().contains('duplicate key') || 
          e.toString().contains('unique constraint')) {
        if (e.toString().contains('username')) {
          throw AuthException('Username sudah digunakan. Silakan pilih username lain.');
        }
        if (e.toString().contains('email')) {
          throw AuthException('Email sudah digunakan. Silakan pilih email lain.');
        }
        throw AuthException('Data sudah digunakan. Silakan pilih yang lain.');
      }
      throw ServerException('Gagal memperbarui data pengguna: $e');
    }
  }

  @override
  Future<AuthUserModel> updateCredentials({String? email, String? password}) async {
    try {
      await SupabaseConfig.client.auth.updateUser(sfb.UserAttributes(
        email: email,
        password: password,
      ));

      final current = SupabaseConfig.client.auth.currentUser;
      if (current == null) {
        throw const AuthException('Tidak ada user yang login');
      }

      Map<String, dynamic> response;
      if (email != null && email.isNotEmpty) {
        response = await SupabaseConfig.client
            .from('users')
            .update({'email': email})
            .eq('id', current.id)
            .select()
            .single();
      } else {
        response = await SupabaseConfig.client
            .from('users')
            .select()
            .eq('id', current.id)
            .single();
      }

      return AuthUserModel.fromJson(response);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Gagal memperbarui kredensial: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required String imagePath,
  }) async {
    try {
      // Baca file dari path (path dari XFile lebih reliable)
      final imageFile = File(imagePath);
      
      // Pastikan file exists
      if (!await imageFile.exists()) {
        throw AuthException('File gambar tidak ditemukan. Silakan pilih gambar lagi.');
      }
      
      // Generate nama file unik dengan timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId/$timestamp.jpg';
      
      // Upload ke Supabase Storage bucket 'avatars'
      // Pastikan bucket 'avatars' sudah dibuat di Supabase Storage
      await SupabaseConfig.client.storage
          .from('avatars')
          .upload(fileName, imageFile, fileOptions: sfb.FileOptions(
            upsert: true, // Replace file jika sudah ada
            contentType: 'image/jpeg',
          ));

      // Dapatkan public URL dari file yang sudah diupload
      final publicUrl = SupabaseConfig.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      // Handle error spesifik
      if (e is AuthException) {
        rethrow;
      }
      if (e.toString().contains('Bucket not found') ||
          e.toString().contains('bucket')) {
        throw AuthException(
          'Bucket "avatars" belum dibuat di Supabase Storage. '
          'Silakan buat bucket "avatars" di Supabase Dashboard → Storage.',
        );
      }
      if (e.toString().contains('permission denied') ||
          e.toString().contains('policy') ||
          e.toString().contains('RLS') ||
          e.toString().contains('new row violates row-level security')) {
        throw AuthException(
          'Tidak memiliki izin untuk upload gambar.\n\n'
          'Langkah perbaikan:\n'
          '1. Buka Supabase Dashboard → Storage\n'
          '2. Pastikan bucket "avatars" sudah dibuat dan set sebagai PUBLIC\n'
          '3. Buka SQL Editor dan jalankan script: database/setup_storage_policy.sql\n'
          '4. Refresh aplikasi setelah setup\n\n'
          'Lihat file database/STORAGE_SETUP.md untuk panduan lengkap.'
        );
      }
      if (e.toString().contains('_Namespace') ||
          e.toString().contains('Unsupported operation')) {
        throw AuthException(
          'Gagal mengakses file. Pastikan aplikasi memiliki izin akses file. '
          'Jika masalah berlanjut, coba restart aplikasi.',
        );
      }
      throw AuthException('Gagal mengupload avatar: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadAvatarBytes({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    File? tempFile;
    try {
      // Generate nama file unik dengan timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId/$timestamp.jpg';
      
      // Gunakan path sederhana yang tidak memerlukan path_provider
      // Coba beberapa lokasi yang mungkin bisa diakses
      final possiblePaths = [
        'avatar_$timestamp.jpg', // Path relatif
        './avatar_$timestamp.jpg', // Path relatif dengan prefix
      ];
      
      File? createdFile;
      for (final path in possiblePaths) {
        try {
          final file = File(path);
          await file.writeAsBytes(imageBytes);
          
          if (await file.exists()) {
            createdFile = file;
            tempFile = file;
            break;
          }
        } catch (_) {
          // Coba path berikutnya
          continue;
        }
      }
      
      if (createdFile == null) {
        throw AuthException(
          'Gagal membuat file temporary untuk upload. '
          'Pastikan aplikasi memiliki izin akses penyimpanan. '
          'Coba restart aplikasi atau rebuild aplikasi.'
        );
      }
      
      // Upload ke Supabase Storage bucket 'avatars'
      try {
        await SupabaseConfig.client.storage
            .from('avatars')
            .upload(fileName, createdFile, fileOptions: sfb.FileOptions(
              upsert: true, // Replace file jika sudah ada
              contentType: 'image/jpeg',
            ));
      } catch (uploadError) {
        // Log error untuk debugging
        print('Upload error: ${uploadError.toString()}');
        rethrow;
      }

      // Dapatkan public URL dari file yang sudah diupload
      final publicUrl = SupabaseConfig.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      // Handle error spesifik
      if (e is AuthException) {
        rethrow;
      }
      
      // Log error untuk debugging
      print('Upload avatar error: ${e.toString()}');
      print('Error type: ${e.runtimeType}');
      
      if (e.toString().contains('Bucket not found') ||
          e.toString().contains('bucket') ||
          e.toString().contains('does not exist')) {
        throw AuthException(
          'Bucket "avatars" belum dibuat di Supabase Storage. '
          'Silakan buat bucket "avatars" di Supabase Dashboard → Storage.',
        );
      }
      if (e.toString().contains('permission denied') ||
          e.toString().contains('policy') ||
          e.toString().contains('RLS') ||
          e.toString().contains('new row violates row-level security')) {
        throw AuthException(
          'Tidak memiliki izin untuk upload gambar.\n\n'
          'Langkah perbaikan:\n'
          '1. Buka Supabase Dashboard → Storage\n'
          '2. Pastikan bucket "avatars" sudah dibuat dan set sebagai PUBLIC\n'
          '3. Buka SQL Editor dan jalankan script: database/setup_storage_policy.sql\n'
          '4. Refresh aplikasi setelah setup\n\n'
          'Lihat file database/STORAGE_SETUP.md untuk panduan lengkap.'
        );
      }
      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('_Namespace') ||
          e.toString().contains('Unsupported operation')) {
        throw AuthException(
          'Gagal mengakses file sistem. '
          'Coba gunakan path dari gambar yang dipilih langsung. '
          'Jika masalah berlanjut, restart aplikasi atau rebuild aplikasi. '
          'Error: ${e.toString()}',
        );
      }
      throw AuthException('Gagal mengupload avatar: ${e.toString()}');
    } finally {
      // Hapus file temporary setelah upload
      if (tempFile != null) {
        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (deleteError) {
          // Log error saat menghapus (tidak critical)
          print('Warning: Gagal menghapus file temporary: ${deleteError.toString()}');
        }
      }
    }
  }
}

