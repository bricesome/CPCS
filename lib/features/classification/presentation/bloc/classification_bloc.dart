import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/classification_usecases.dart';
import 'classification_event.dart';
import 'classification_state.dart';

export 'classification_event.dart';
export 'classification_state.dart';

class ClassificationBloc
    extends Bloc<ClassificationEvent, ClassificationState> {
  final GetClassificationUseCase getClassificationUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final GetRecentsUseCase getRecentsUseCase;
  final AddRecentUseCase addRecentUseCase;
  final GetLearningModeUseCase getLearningModeUseCase;
  final SetLearningModeUseCase setLearningModeUseCase;

  ClassificationBloc({
    required this.getClassificationUseCase,
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
    required this.getRecentsUseCase,
    required this.addRecentUseCase,
    required this.getLearningModeUseCase,
    required this.setLearningModeUseCase,
  }) : super(const ClassificationState()) {
    on<LoadClassification>(_onLoad);
    on<ToggleFavorite>(_onToggleFavorite);
    on<VisitUnit>(_onVisit);
    on<ToggleLearningMode>(_onToggleLearningMode);
  }

  Future<void> _onLoad(
    LoadClassification event,
    Emitter<ClassificationState> emit,
  ) async {
    emit(state.copyWith(status: ClassificationStatus.loading));
    final result = await getClassificationUseCase(NoParams());
    final favorites = await getFavoritesUseCase(NoParams());
    final recents = await getRecentsUseCase(NoParams());
    final learning = await getLearningModeUseCase(NoParams());
    result.match(
      (failure) => emit(
        state.copyWith(
          status: ClassificationStatus.error,
          error: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: ClassificationStatus.loaded,
          data: data,
          favorites: favorites.getOrElse((_) => const []),
          recents: recents.getOrElse((_) => const []),
          learningMode: learning.getOrElse((_) => true),
        ),
      ),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<ClassificationState> emit,
  ) async {
    final result = await toggleFavoriteUseCase(event.unitId);
    result.match((_) {}, (list) => emit(state.copyWith(favorites: list)));
  }

  Future<void> _onVisit(
    VisitUnit event,
    Emitter<ClassificationState> emit,
  ) async {
    final result = await addRecentUseCase(event.unitId);
    result.match((_) {}, (list) => emit(state.copyWith(recents: list)));
  }

  Future<void> _onToggleLearningMode(
    ToggleLearningMode event,
    Emitter<ClassificationState> emit,
  ) async {
    final result = await setLearningModeUseCase(!state.learningMode);
    result.match((_) {}, (v) => emit(state.copyWith(learningMode: v)));
  }
}
