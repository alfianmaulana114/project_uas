import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class UpdateUserUsecase implements UseCase<AuthUser, AuthUser> {
  final AuthRepository repository;

  UpdateUserUsecase(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(AuthUser params) async {
    return await repository.updateUser(params);
  }
}