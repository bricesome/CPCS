import '../../domain/entities/classification.dart';
import '../../domain/entities/criterion.dart';
import '../../domain/entities/soil_unit.dart';

/// Conversion du JSON de référence (assets/data/cpcs_1967.json) en entités.
class ClassificationModel {
  const ClassificationModel._();

  static Classification fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>;

    final levels =
        (json['levels'] as List)
            .cast<Map<String, dynamic>>()
            .map(
              (l) => SoilLevel(
                id: soilLevelFromJson(l['id'] as String),
                label: l['label'] as String,
                explanation: l['explanation'] as String,
              ),
            )
            .toList();

    final criteria =
        (json['criteria'] as List)
            .cast<Map<String, dynamic>>()
            .map(
              (c) => Criterion(
                id: c['id'] as String,
                label: c['label'] as String,
                explanation: c['explanation'] as String,
                values:
                    (c['values'] as List)
                        .cast<Map<String, dynamic>>()
                        .map(
                          (v) => CriterionValue(
                            id: v['id'] as String,
                            label: v['label'] as String,
                            explanation: v['explanation'] as String,
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();

    final effective = <String, Map<String, Set<String>>>{};
    final units = <SoilUnit>[];
    final rawUnits = (json['units'] as List).cast<Map<String, dynamic>>();
    for (var i = 0; i < rawUnits.length; i++) {
      final u = rawUnits[i];
      final id = u['id'] as String;
      final parentId = u['parent'] as String?;
      final own = (u['criteria'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(k, (v as List).cast<String>()),
      );
      final inherited = parentId == null ? null : effective[parentId];
      final merged = <String, Set<String>>{
        if (inherited != null)
          for (final e in inherited.entries) e.key: e.value,
        for (final e in own.entries) e.key: e.value.toSet(),
      };
      effective[id] = merged;
      units.add(
        SoilUnit(
          id: id,
          code: u['code'] as String,
          level: soilLevelFromJson(u['level'] as String),
          name: u['name'] as String,
          description: u['description'] as String,
          parentId: parentId,
          order: i,
          ownCriteria: own,
          criteria: merged,
          explanation: u['explanation'] as String?,
          profile: u['profile'] as String?,
          examples: u['examples'] as String?,
        ),
      );
    }

    final keyQuestions =
        (json['key'] as List)
            .cast<Map<String, dynamic>>()
            .map(
              (q) => KeyQuestion(
                id: q['id'] as String,
                question: q['question'] as String,
                help: q['help'] as String,
                options:
                    (q['options'] as List)
                        .cast<Map<String, dynamic>>()
                        .map(
                          (o) => KeyOption(
                            label: o['label'] as String,
                            target: o['target'] as String,
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();

    final glossary =
        (json['glossary'] as List)
            .cast<Map<String, dynamic>>()
            .map(
              (g) => GlossaryEntry(
                term: g['term'] as String,
                definition: g['definition'] as String,
              ),
            )
            .toList();

    return Classification(
      title: meta['title'] as String,
      source: meta['source'] as String,
      note: meta['note'] as String,
      levels: levels,
      criteria: criteria,
      units: units,
      keyQuestions: keyQuestions,
      glossary: glossary,
    );
  }
}
