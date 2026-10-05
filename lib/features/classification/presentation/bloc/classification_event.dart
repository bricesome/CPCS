import 'package:equatable/equatable.dart';

abstract class ClassificationEvent extends Equatable {
  const ClassificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadClassification extends ClassificationEvent {}

class ToggleFavorite extends ClassificationEvent {
  final String unitId;
  const ToggleFavorite(this.unitId);

  @override
  List<Object?> get props => [unitId];
}

class VisitUnit extends ClassificationEvent {
  final String unitId;
  const VisitUnit(this.unitId);

  @override
  List<Object?> get props => [unitId];
}

class ToggleLearningMode extends ClassificationEvent {}
