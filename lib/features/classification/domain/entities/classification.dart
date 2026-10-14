import 'package:equatable/equatable.dart';

import '../../../lab/domain/entities/lab.dart';
import 'criterion.dart';
import 'soil_unit.dart';

class KeyOption extends Equatable {
  final String label;
  final String target;

  const KeyOption({required this.label, required this.target});

  bool get isResult => target.startsWith('r:');
  String get resultId => target.substring(2);

  @override
  List<Object?> get props => [label, target];
}

class KeyQuestion extends Equatable {
  final String id;
  final String question;
  final String help;
  final List<KeyOption> options;

  const KeyQuestion({
    required this.id,
    required this.question,
    required this.help,
    required this.options,
  });

  @override
  List<Object?> get props => [id];
}

class GlossaryEntry extends Equatable {
  final String term;
  final String definition;

  const GlossaryEntry({required this.term, required this.definition});

  @override
  List<Object?> get props => [term];
}

class Credit extends Equatable {
  final String role;
  final String name;

  const Credit({required this.role, required this.name});

  @override
  List<Object?> get props => [role, name];
}

/// Rubrique du guide d'utilisation de l'application.
class GuideSection extends Equatable {
  final String id;
  final String title;
  final String what;
  final List<String> steps;
  final String example;

  const GuideSection({
    required this.id,
    required this.title,
    required this.what,
    required this.steps,
    required this.example,
  });

  @override
  List<Object?> get props => [id];
}

/// Référentiel complet : hiérarchie, critères, clé et glossaire.
class Classification {
  final String title;
  final String source;
  final String note;
  final List<SoilLevel> levels;
  final List<Criterion> criteria;
  final List<SoilUnit> units;
  final List<KeyQuestion> keyQuestions;
  final List<GlossaryEntry> glossary;
  final List<Credit> credits;
  final LabData lab;
  final List<GuideSection> guide;

  final Map<String, SoilUnit> _byId;
  final Map<String, List<SoilUnit>> _children;

  Classification({
    required this.title,
    required this.source,
    required this.note,
    required this.levels,
    required this.criteria,
    required this.units,
    required this.keyQuestions,
    required this.glossary,
    this.credits = const [],
    this.lab = const LabData(),
    this.guide = const [],
  }) : _byId = {for (final u in units) u.id: u},
       _children = _indexChildren(units);

  static Map<String, List<SoilUnit>> _indexChildren(List<SoilUnit> units) {
    final map = <String, List<SoilUnit>>{};
    for (final u in units) {
      map.putIfAbsent(u.parentId ?? '', () => []).add(u);
    }
    return map;
  }

  List<SoilUnit> get roots => _children[''] ?? const [];

  SoilUnit? unit(String id) => _byId[id];

  List<SoilUnit> childrenOf(String id) => _children[id] ?? const [];

  /// Du sommet (classe) jusqu'au parent direct.
  List<SoilUnit> ancestorsOf(String id) {
    final chain = <SoilUnit>[];
    var current = _byId[id]?.parentId;
    while (current != null) {
      final u = _byId[current];
      if (u == null) break;
      chain.insert(0, u);
      current = u.parentId;
    }
    return chain;
  }

  SoilLevel level(SoilLevelId id) => levels.firstWhere((l) => l.id == id);

  Criterion? criterion(String id) {
    for (final c in criteria) {
      if (c.id == id) return c;
    }
    return null;
  }

  GuideSection? guideSection(String id) {
    for (final g in guide) {
      if (g.id == id) return g;
    }
    return null;
  }

  KeyQuestion? keyQuestion(String id) {
    for (final q in keyQuestions) {
      if (q.id == id) return q;
    }
    return null;
  }

  /// Nom complet d'un sous-groupe (« Sols bruns › Lessivé »).
  String fullName(SoilUnit unit) {
    if (unit.level != SoilLevelId.sousGroupe) return unit.name;
    final parent = unit.parentId == null ? null : _byId[unit.parentId!];
    return parent == null ? unit.name : '${parent.name} › ${unit.name}';
  }
}
