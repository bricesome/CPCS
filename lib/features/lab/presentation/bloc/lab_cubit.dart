import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/lab.dart';
import '../../domain/services/lab_analyzer.dart';

class LabState extends Equatable {
  final Map<String, Object> measures;
  final List<LabResult>? results;
  final String? presetName;

  const LabState({this.measures = const {}, this.results, this.presetName});

  @override
  List<Object?> get props => [measures, results, presetName];
}

class LabCubit extends Cubit<LabState> {
  final LabData lab;

  LabCubit(this.lab) : super(const LabState());

  void setMeasure(String parameterId, Object? value) {
    final next = Map<String, Object>.from(state.measures);
    if (value == null) {
      next.remove(parameterId);
    } else {
      next[parameterId] = value;
    }
    emit(LabState(measures: next));
  }

  void loadPreset(LabPreset preset) {
    emit(
      LabState(
        measures: Map<String, Object>.from(preset.measures),
        presetName: preset.name,
      ),
    );
    analyze();
  }

  void analyze() {
    emit(
      LabState(
        measures: state.measures,
        presetName: state.presetName,
        results: LabAnalyzer.analyze(lab, state.measures),
      ),
    );
  }

  void clear() => emit(const LabState());
}
