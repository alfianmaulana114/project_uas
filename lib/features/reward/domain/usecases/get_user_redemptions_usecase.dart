import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reward_redemption.dart';
import '../repositories/reward_repository.dart';

class GetUserRedemptionsUsecase {
  final RewardRepository repository;

  GetUserRedemptionsUsecase(this.repository);

  Future<Either<Failure, List<RewardRedemption>>> call({int limit = 50}) async {
    return await repository.getUserRedemptions(limit: limit);
  }
}

