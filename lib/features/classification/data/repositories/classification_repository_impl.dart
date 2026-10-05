import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/classification.dart';
import '../../domain/repositories/classification_repository.dart';
import '../datasources/classification_asset_data_source.dart';
import '../datasources/user_prefs_local_data_source.dart';

class ClassificationRepositoryImpl implements ClassificationRepository {
  static const favoritesKey = 'favorites';
  static const recentsKey = 'recents';
  static const learningModeKey = 'learning_mode';
  static const maxRecents = 12;

  final ClassificationAssetDataSource assets;
  final UserPrefsLocalDataSource prefs;

  ClassificationRepositoryImpl({required this.assets, required this.prefs});

  @override
  Future<Either<Failure, Classification>> getClassification() async {
    try {
      return Right(await assets.load());
    } catch (e) {
      return Left(DataFailure('Lecture de la classification impossible : $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFavorites() =>
      _guard(() async => prefs.readList(favoritesKey));

  @override
  Future<Either<Failure, List<String>>> toggleFavorite(String unitId) =>
      _guard(() async {
        final list = prefs.readList(favoritesKey);
        if (!list.remove(unitId)) list.add(unitId);
        await prefs.writeList(favoritesKey, list);
        return list;
      });

  @override
  Future<Either<Failure, List<String>>> getRecents() =>
      _guard(() async => prefs.readList(recentsKey));

  @override
  Future<Either<Failure, List<String>>> addRecent(String unitId) =>
      _guard(() async {
        final list =
            prefs.readList(recentsKey)
              ..remove(unitId)
              ..insert(0, unitId);
        final trimmed = list.take(maxRecents).toList();
        await prefs.writeList(recentsKey, trimmed);
        return trimmed;
      });

  @override
  Future<Either<Failure, bool>> getLearningMode() =>
      _guard(() async => prefs.readBool(learningModeKey, fallback: true));

  @override
  Future<Either<Failure, bool>> setLearningMode(bool enabled) =>
      _guard(() async {
        await prefs.writeBool(learningModeKey, enabled);
        return enabled;
      });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
