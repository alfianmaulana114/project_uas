import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case untuk sign out user
/// Mengikuti konsep Single Responsibility Principle (SOLID)
/// Setiap use case memiliki satu tanggung jawab
class SignOutUsecase {
  /// Instance dari AuthRepository
  /// Menggunakan dependency injection untuk loose coupling
  final AuthRepository repository;

  /// Constructor untuk SignOutUsecase
  /// [repository] adalah instance dari AuthRepository
  SignOutUsecase(this.repository);

  /// Method untuk execute sign out
  /// Tidak memerlukan parameter
  /// Mengembalikan Either<Failure, void>
  Future<Either<Failure, void>> call() async {
    /// Memanggil repository untuk melakukan sign out
    return await repository.signOut();
  }
}

