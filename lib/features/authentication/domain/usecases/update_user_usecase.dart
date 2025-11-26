import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class UpdateUserUsecase {
  final AuthRepository repository;

  UpdateUserUsecase(this.repository);

  Future<Either<Failure, AuthUser>> call(AuthUser params) async {
    return await repository.updateUser(params);
  }
}