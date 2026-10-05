import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/classification.dart';

abstract class ClassificationRepository {
  Future<Either<Failure, Classification>> getClassification();
  Future<Either<Failure, List<String>>> getFavorites();
  Future<Either<Failure, List<String>>> toggleFavorite(String unitId);
  Future<Either<Failure, List<String>>> getRecents();
  Future<Either<Failure, List<String>>> addRecent(String unitId);
  Future<Either<Failure, bool>> getLearningMode();
  Future<Either<Failure, bool>> setLearningMode(bool enabled);
}
