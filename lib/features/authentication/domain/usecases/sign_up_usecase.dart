import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case untuk sign up user baru
/// Mengikuti konsep Single Responsibility Principle (SOLID)
/// Setiap use case memiliki satu tanggung jawab
class SignUpUsecase {
  /// Instance dari AuthRepository
  /// Menggunakan dependency injection untuk loose coupling
  final AuthRepository repository;

  /// Constructor untuk SignUpUsecase
  /// [repository] adalah instance dari AuthRepository
  SignUpUsecase(this.repository);

  /// Method untuk execute sign up
  /// [params] adalah parameter yang berisi email, password, fullName, dan username
  /// Mengembalikan Either<Failure, AuthUser>
  Future<Either<Failure, AuthUser>> call(SignUpParams params) async {
    /// Validasi email dan password sebelum melakukan sign up
    if (params.email.isEmpty) {
      return Left(AuthFailure('Email tidak boleh kosong'));
    }
    if (params.password.isEmpty) {
      return Left(AuthFailure('Password tidak boleh kosong'));
    }
    if (params.password.length < 6) {
      return Left(AuthFailure('Password minimal 6 karakter'));
    }

    /// Memanggil repository untuk melakukan sign up
    return await repository.signUp(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      username: params.username,
    );
  }
}

/// Class untuk parameter SignUpUsecase
/// Menggunakan class terpisah untuk parameter (bukan Map)
/// Mengikuti konsep type safety
class SignUpParams {
  /// Email user
  final String email;

  /// Password user
  final String password;

  /// Nama lengkap user (opsional)
  final String? fullName;

  /// Username user (opsional)
  final String? username;

  /// Constructor untuk SignUpParams
  const SignUpParams({
    required this.email,
    required this.password,
    this.fullName,
    this.username,
  });
}

