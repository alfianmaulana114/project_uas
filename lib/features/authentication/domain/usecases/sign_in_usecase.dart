import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case untuk sign in user
/// Mengikuti konsep Single Responsibility Principle (SOLID)
/// Setiap use case memiliki satu tanggung jawab
class SignInUsecase {
  /// Instance dari AuthRepository
  /// Menggunakan dependency injection untuk loose coupling
  final AuthRepository repository;

  /// Constructor untuk SignInUsecase
  /// [repository] adalah instance dari AuthRepository
  SignInUsecase(this.repository);

  /// Method untuk execute sign in
  /// [params] adalah parameter yang berisi email dan password
  /// Mengembalikan Either<Failure, AuthUser>
  Future<Either<Failure, AuthUser>> call(SignInParams params) async {
    /// Validasi email dan password sebelum melakukan sign in
    if (params.email.isEmpty) {
      return Left(AuthFailure('Email tidak boleh kosong'));
    }
    if (params.password.isEmpty) {
      return Left(AuthFailure('Password tidak boleh kosong'));
    }

    /// Memanggil repository untuk melakukan sign in
    return await repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}

/// Class untuk parameter SignInUsecase
/// Menggunakan class terpisah untuk parameter (bukan Map)
/// Mengikuti konsep type safety
class SignInParams {
  /// Email user
  final String email;

  /// Password user
  final String password;

  /// Constructor untuk SignInParams
  const SignInParams({
    required this.email,
    required this.password,
  });
}

