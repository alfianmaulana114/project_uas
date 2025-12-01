import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/reward_repository.dart';

class AddPointsUsecase {
  final RewardRepository repository;

  AddPointsUsecase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({required int points}) async {
    return await repository.addPoints(points: points);
  }
}

