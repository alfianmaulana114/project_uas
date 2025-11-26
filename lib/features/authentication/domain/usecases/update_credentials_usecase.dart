import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class UpdateCredentialsUsecase {
  final AuthRepository repository;

  UpdateCredentialsUsecase(this.repository);

  Future<Either<Failure, AuthUser>> call(UpdateCredentialsParams params) async {
    return await repository.updateCredentials(
      email: params.email,
      password: params.password,
    );
  }
}

class UpdateCredentialsParams {
  final String? email;
  final String? password;

  const UpdateCredentialsParams({this.email, this.password});
}
