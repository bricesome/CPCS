import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../classification/domain/entities/classification.dart';

class DeterminationStep extends Equatable {
  final String questionId;
  final String answer;
  const DeterminationStep(this.questionId, this.answer);

  @override
  List<Object?> get props => [questionId, answer];
}

class DeterminationState extends Equatable {
  final String? currentQuestionId;
  final List<DeterminationStep> history;
  final String? resultId;

  const DeterminationState({
    this.currentQuestionId,
    this.history = const [],
    this.resultId,
  });

  @override
  List<Object?> get props => [currentQuestionId, history, resultId];
}

/// Clé de détermination : questions successives jusqu'à une classe.
class DeterminationCubit extends Cubit<DeterminationState> {
  final String firstQuestionId;

  DeterminationCubit({required this.firstQuestionId})
    : super(DeterminationState(currentQuestionId: firstQuestionId));

  void answer(KeyQuestion question, KeyOption option) {
    final history = [
      ...state.history,
      DeterminationStep(question.id, option.label),
    ];
    if (option.isResult) {
      emit(DeterminationState(history: history, resultId: option.resultId));
    } else {
      emit(
        DeterminationState(currentQuestionId: option.target, history: history),
      );
    }
  }

  void back() {
    if (state.history.isEmpty) return;
    final history = [...state.history]..removeLast();
    final previous = state.history.last.questionId;
    emit(DeterminationState(currentQuestionId: previous, history: history));
  }

  void restart() =>
      emit(DeterminationState(currentQuestionId: firstQuestionId));
}
