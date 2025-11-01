import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case untuk mendapatkan user yang sedang login
/// Mengikuti konsep Single Responsibility Principle (SOLID)
/// Setiap use case memiliki satu tanggung jawab
class GetCurrentUserUsecase {
  /// Instance dari AuthRepository
  /// Menggunakan dependency injection untuk loose coupling
  final AuthRepository repository;

  /// Constructor untuk GetCurrentUserUsecase
  /// [repository] adalah instance dari AuthRepository
  GetCurrentUserUsecase(this.repository);

  /// Method untuk execute get current user
  /// Tidak memerlukan parameter
  /// Mengembalikan Either<Failure, AuthUser?>
  /// AuthUser? bisa null jika tidak ada user yang login
  Future<Either<Failure, AuthUser?>> call() async {
    /// Memanggil repository untuk mendapatkan current user
    return await repository.getCurrentUser();
  }
}

