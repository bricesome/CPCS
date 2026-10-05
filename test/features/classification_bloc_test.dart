import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nana_doc/features/classification/data/datasources/user_prefs_local_data_source.dart';
import 'package:nana_doc/features/classification/data/repositories/classification_repository_impl.dart';
import 'package:nana_doc/features/classification/domain/usecases/classification_usecases.dart';
import 'package:nana_doc/features/classification/presentation/bloc/classification_bloc.dart';

import '../helpers/test_data.dart';

ClassificationBloc buildBloc() {
  final repo = ClassificationRepositoryImpl(
    assets: FileAssetDataSource(),
    prefs: InMemoryUserPrefsLocalDataSource(),
  );
  return ClassificationBloc(
    getClassificationUseCase: GetClassificationUseCase(repo),
    getFavoritesUseCase: GetFavoritesUseCase(repo),
    toggleFavoriteUseCase: ToggleFavoriteUseCase(repo),
    getRecentsUseCase: GetRecentsUseCase(repo),
    addRecentUseCase: AddRecentUseCase(repo),
    getLearningModeUseCase: GetLearningModeUseCase(repo),
    setLearningModeUseCase: SetLearningModeUseCase(repo),
  );
}

void main() {
  blocTest<ClassificationBloc, ClassificationState>(
    'charge le référentiel',
    build: buildBloc,
    act: (bloc) => bloc.add(LoadClassification()),
    verify: (bloc) {
      expect(bloc.state.status, ClassificationStatus.loaded);
      expect(bloc.state.data!.roots.length, 12);
      expect(bloc.state.learningMode, isTrue);
    },
  );

  blocTest<ClassificationBloc, ClassificationState>(
    'favoris, récents et mode apprentissage',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(LoadClassification());
      await Future<void>.delayed(Duration.zero);
      bloc
        ..add(const ToggleFavorite('III'))
        ..add(const VisitUnit('IX'))
        ..add(const VisitUnit('III'))
        ..add(ToggleLearningMode());
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.favorites, ['III']);
      expect(bloc.state.recents, ['III', 'IX']);
      expect(bloc.state.learningMode, isFalse);
    },
  );
}
