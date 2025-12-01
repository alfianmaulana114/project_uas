import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reward_item.dart';
import '../repositories/reward_repository.dart';

class GetAllRewardItemsUsecase {
  final RewardRepository repository;

  GetAllRewardItemsUsecase(this.repository);

  Future<Either<Failure, List<RewardItem>>> call({String? category}) async {
    return await repository.getAllRewardItems(category: category);
  }
}

