import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/challenge.dart';
import '../repositories/challenge_repository.dart';

class GetAllChallengesUsecase {
  final ChallengeRepository repository;
  GetAllChallengesUsecase(this.repository);

  Future<Either<Failure, List<Challenge>>> call({String? category}) {
    return repository.getAllChallenges(category: category);
  }
}


