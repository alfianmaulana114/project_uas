import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';

/// Abstract repository untuk authentication
/// Mengikuti Dependency Inversion Principle (SOLID)
/// Menggunakan Either dari package dartz untuk error handling
abstract class AuthRepository {
  /// Method untuk sign in user dengan email dan password
  /// Mengembalikan Either<Failure, AuthUser>
  /// Left = Failure, Right = AuthUser
  /// [email] adalah email user
  /// [password] adalah password user
  Future<Either<Failure, AuthUser>> signIn({
    required String email,
    required String password,
  });

  /// Method untuk sign up user baru
  /// Mengembalikan Either<Failure, AuthUser>
  /// Left = Failure, Right = AuthUser
  /// [email] adalah email user
  /// [password] adalah password user
  /// [fullName] adalah nama lengkap user (opsional)
  /// [username] adalah username user (opsional)
  Future<Either<Failure, AuthUser>> signUp({
    required String email,
    required String password,
    String? fullName,
    String? username,
  });

  /// Method untuk sign out user
  /// Mengembalikan Either<Failure, void>
  /// Left = Failure, Right = void (success)
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, AuthUser>> updateUser(AuthUser user);
  Future<Either<Failure, AuthUser>> updateCredentials({String? email, String? password});

  /// Method untuk mendapatkan user yang sedang login
  /// Mengembalikan Either<Failure, AuthUser?>
  /// Left = Failure, Right = AuthUser? (null jika tidak ada user yang login)
  Future<Either<Failure, AuthUser?>> getCurrentUser();

  /// Method untuk upload avatar ke Supabase Storage
  /// Mengembalikan Either<Failure, String> (URL avatar)
  /// Left = Failure, Right = String (URL avatar)
  /// [userId] adalah ID user
  /// [imagePath] adalah path file gambar yang akan diupload
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required String imagePath,
  });

  /// Method untuk upload avatar ke Supabase Storage dengan bytes
  /// Mengembalikan Either<Failure, String> (URL avatar)
  /// Left = Failure, Right = String (URL avatar)
  /// [userId] adalah ID user
  /// [imageBytes] adalah bytes dari gambar yang akan diupload
  Future<Either<Failure, String>> uploadAvatarBytes({
    required String userId,
    required Uint8List imageBytes,
  });
}

