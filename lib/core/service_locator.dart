import 'package:get_it/get_it.dart';

import '../features/classification/data/datasources/classification_asset_data_source.dart';
import '../features/classification/data/datasources/user_prefs_local_data_source.dart';
import '../features/classification/data/repositories/classification_repository_impl.dart';
import '../features/classification/domain/repositories/classification_repository.dart';
import '../features/classification/domain/usecases/classification_usecases.dart';
import '../features/classification/presentation/bloc/classification_bloc.dart';

final sl = GetIt.instance;

Future<void> init({
  UserPrefsLocalDataSource? prefs,
  ClassificationAssetDataSource? assets,
}) async {
  // Bloc
  sl.registerFactory(
    () => ClassificationBloc(
      getClassificationUseCase: sl(),
      getFavoritesUseCase: sl(),
      toggleFavoriteUseCase: sl(),
      getRecentsUseCase: sl(),
      addRecentUseCase: sl(),
      getLearningModeUseCase: sl(),
      setLearningModeUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetClassificationUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentsUseCase(sl()));
  sl.registerLazySingleton(() => AddRecentUseCase(sl()));
  sl.registerLazySingleton(() => GetLearningModeUseCase(sl()));
  sl.registerLazySingleton(() => SetLearningModeUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ClassificationRepository>(
    () => ClassificationRepositoryImpl(assets: sl(), prefs: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ClassificationAssetDataSource>(
    () => assets ?? ClassificationAssetDataSourceImpl(),
  );
  sl.registerLazySingleton<UserPrefsLocalDataSource>(
    () => prefs ?? HiveUserPrefsLocalDataSource(),
  );
}
