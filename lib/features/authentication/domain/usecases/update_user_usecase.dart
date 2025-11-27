import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case untuk update user
/// Mengikuti konsep Single Responsibility Principle (SOLID)
class UpdateUserUsecase {
  /// Instance dari AuthRepository
  final AuthRepository repository;

  /// Constructor untuk UpdateUserUsecase
  UpdateUserUsecase(this.repository);

  /// Method untuk execute update user
  /// [user] adalah user yang akan diupdate
  /// Mengembalikan Either<Failure, AuthUser>
  Future<Either<Failure, AuthUser>> call(AuthUser user) async {
    return await repository.updateUser(user);
  }
}