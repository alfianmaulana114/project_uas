import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/reward_repository.dart';

class RedeemRewardUsecase {
  final RewardRepository repository;

  RedeemRewardUsecase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({required String rewardItemId}) async {
    return await repository.redeemReward(rewardItemId: rewardItemId);
  }
}

