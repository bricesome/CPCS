import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/classification.dart';
import '../repositories/classification_repository.dart';

class GetClassificationUseCase implements UseCase<Classification, NoParams> {
  final ClassificationRepository repository;
  GetClassificationUseCase(this.repository);

  @override
  Future<Either<Failure, Classification>> call(NoParams params) =>
      repository.getClassification();
}

class GetFavoritesUseCase implements UseCase<List<String>, NoParams> {
  final ClassificationRepository repository;
  GetFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) =>
      repository.getFavorites();
}

class ToggleFavoriteUseCase implements UseCase<List<String>, String> {
  final ClassificationRepository repository;
  ToggleFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String unitId) =>
      repository.toggleFavorite(unitId);
}

class GetRecentsUseCase implements UseCase<List<String>, NoParams> {
  final ClassificationRepository repository;
  GetRecentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) =>
      repository.getRecents();
}

class AddRecentUseCase implements UseCase<List<String>, String> {
  final ClassificationRepository repository;
  AddRecentUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String unitId) =>
      repository.addRecent(unitId);
}

class GetLearningModeUseCase implements UseCase<bool, NoParams> {
  final ClassificationRepository repository;
  GetLearningModeUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      repository.getLearningMode();
}

class SetLearningModeUseCase implements UseCase<bool, bool> {
  final ClassificationRepository repository;
  SetLearningModeUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(bool enabled) =>
      repository.setLearningMode(enabled);
}
