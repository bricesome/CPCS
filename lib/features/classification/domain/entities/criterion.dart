import 'package:equatable/equatable.dart';

class CriterionValue extends Equatable {
  final String id;
  final String label;
  final String explanation;

  const CriterionValue({
    required this.id,
    required this.label,
    required this.explanation,
  });

  @override
  List<Object?> get props => [id];
}

/// Facette de croisement (processus, climat, matériau, ...).
class Criterion extends Equatable {
  final String id;
  final String label;
  final String explanation;
  final List<CriterionValue> values;

  const Criterion({
    required this.id,
    required this.label,
    required this.explanation,
    required this.values,
  });

  CriterionValue? value(String valueId) {
    for (final v in values) {
      if (v.id == valueId) return v;
    }
    return null;
  }

  @override
  List<Object?> get props => [id];
}
