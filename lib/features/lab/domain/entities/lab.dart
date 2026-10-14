import 'package:equatable/equatable.dart';

enum LabKind { choice, range }

class LabOption extends Equatable {
  final String id;
  final String label;
  final String explanation;

  const LabOption({
    required this.id,
    required this.label,
    required this.explanation,
  });

  @override
  List<Object?> get props => [id];
}

/// Paramètre mesuré ou observé sur le terrain (choix ou valeur numérique).
class LabParameter extends Equatable {
  final String id;
  final String label;
  final String explanation;
  final LabKind kind;
  final int weight;
  final List<LabOption> options;
  final double min;
  final double max;
  final double step;
  final double tolerance;
  final String unit;

  const LabParameter({
    required this.id,
    required this.label,
    required this.explanation,
    required this.kind,
    required this.weight,
    this.options = const [],
    this.min = 0,
    this.max = 0,
    this.step = 1,
    this.tolerance = 0,
    this.unit = '',
  });

  LabOption? option(String optionId) {
    for (final o in options) {
      if (o.id == optionId) return o;
    }
    return null;
  }

  @override
  List<Object?> get props => [id];
}

/// Valeur attendue pour un paramètre : liste de choix ou plage [min, max].
class LabExpectation extends Equatable {
  final Set<String> values;
  final double? min;
  final double? max;

  const LabExpectation.values(this.values) : min = null, max = null;
  const LabExpectation.range(double this.min, double this.max)
    : values = const {};

  bool get isRange => min != null;

  @override
  List<Object?> get props => [values, min, max];
}

class LabProfile extends Equatable {
  final String target;
  final Map<String, LabExpectation> expect;

  const LabProfile({required this.target, required this.expect});

  @override
  List<Object?> get props => [target];
}

class LabPreset extends Equatable {
  final String name;
  final Map<String, Object> measures;
  final String expected;

  const LabPreset({
    required this.name,
    required this.measures,
    required this.expected,
  });

  @override
  List<Object?> get props => [name];
}

class LabData {
  final List<LabParameter> parameters;
  final List<LabProfile> profiles;
  final List<LabPreset> presets;

  const LabData({
    this.parameters = const [],
    this.profiles = const [],
    this.presets = const [],
  });

  LabParameter? parameter(String id) {
    for (final p in parameters) {
      if (p.id == id) return p;
    }
    return null;
  }
}
