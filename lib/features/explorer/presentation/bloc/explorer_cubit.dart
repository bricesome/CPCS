import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../classification/domain/entities/soil_unit.dart';

enum ExplorerMode { filters, matrix }

class ExplorerState extends Equatable {
  final Map<String, Set<String>> selection;
  final Set<SoilLevelId> levels;
  final String query;
  final ExplorerMode mode;
  final String rowCriterion;
  final String columnCriterion;
  final SoilLevelId matrixLevel;

  const ExplorerState({
    this.selection = const {},
    this.levels = const {SoilLevelId.groupe},
    this.query = '',
    this.mode = ExplorerMode.filters,
    this.rowCriterion = 'processus',
    this.columnCriterion = 'climat',
    this.matrixLevel = SoilLevelId.groupe,
  });

  int get activeCount => selection.values.fold(0, (n, s) => n + s.length);

  bool isSelected(String criterion, String value) =>
      selection[criterion]?.contains(value) ?? false;

  ExplorerState copyWith({
    Map<String, Set<String>>? selection,
    Set<SoilLevelId>? levels,
    String? query,
    ExplorerMode? mode,
    String? rowCriterion,
    String? columnCriterion,
    SoilLevelId? matrixLevel,
  }) {
    return ExplorerState(
      selection: selection ?? this.selection,
      levels: levels ?? this.levels,
      query: query ?? this.query,
      mode: mode ?? this.mode,
      rowCriterion: rowCriterion ?? this.rowCriterion,
      columnCriterion: columnCriterion ?? this.columnCriterion,
      matrixLevel: matrixLevel ?? this.matrixLevel,
    );
  }

  @override
  List<Object?> get props => [
    selection.map((k, v) => MapEntry(k, v.toList()..sort())).toString(),
    levels.toList(),
    query,
    mode,
    rowCriterion,
    columnCriterion,
    matrixLevel,
  ];
}

class ExplorerCubit extends Cubit<ExplorerState> {
  ExplorerCubit() : super(const ExplorerState());

  void toggleValue(String criterion, String value) {
    final next = {
      for (final e in state.selection.entries) e.key: {...e.value},
    };
    final set = next.putIfAbsent(criterion, () => <String>{});
    if (!set.remove(value)) set.add(value);
    if (set.isEmpty) next.remove(criterion);
    emit(state.copyWith(selection: next));
  }

  void setSelection(
    Map<String, Set<String>> selection, {
    Set<SoilLevelId>? levels,
  }) => emit(
    state.copyWith(
      selection: selection,
      levels: levels,
      mode: ExplorerMode.filters,
    ),
  );

  void clear() => emit(state.copyWith(selection: const {}, query: ''));

  void toggleLevel(SoilLevelId level) {
    final next = {...state.levels};
    if (!next.remove(level)) next.add(level);
    emit(state.copyWith(levels: next));
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setMode(ExplorerMode mode) => emit(state.copyWith(mode: mode));

  void setMatrix({String? row, String? column, SoilLevelId? level}) => emit(
    state.copyWith(
      rowCriterion: row,
      columnCriterion: column,
      matrixLevel: level,
    ),
  );
}
