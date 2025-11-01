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

  /// Method untuk mendapatkan user yang sedang login
  /// Mengembalikan Either<Failure, AuthUser?>
  /// Left = Failure, Right = AuthUser? (null jika tidak ada user yang login)
  Future<Either<Failure, AuthUser?>> getCurrentUser();
}

