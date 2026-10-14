import '../../../lab/domain/entities/lab.dart';
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

    final credits =
        (meta['credits'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(
              (c) =>
                  Credit(role: c['role'] as String, name: c['name'] as String),
            )
            .toList();

    final guide =
        (json['guide'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(
              (g) => GuideSection(
                id: g['id'] as String,
                title: g['title'] as String,
                what: g['what'] as String,
                steps: (g['steps'] as List).cast<String>(),
                example: g['example'] as String,
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
      credits: credits,
      lab: _lab(json['lab'] as Map<String, dynamic>?),
      guide: guide,
    );
  }

  static LabData _lab(Map<String, dynamic>? json) {
    if (json == null) return const LabData();
    final parameters =
        (json['parameters'] as List).cast<Map<String, dynamic>>().map((p) {
          final range = p['kind'] == 'range';
          return LabParameter(
            id: p['id'] as String,
            label: p['label'] as String,
            explanation: p['explanation'] as String,
            kind: range ? LabKind.range : LabKind.choice,
            weight: p['weight'] as int,
            options:
                (p['options'] as List? ?? const [])
                    .cast<Map<String, dynamic>>()
                    .map(
                      (o) => LabOption(
                        id: o['id'] as String,
                        label: o['label'] as String,
                        explanation: o['explanation'] as String,
                      ),
                    )
                    .toList(),
            min: (p['min'] as num? ?? 0).toDouble(),
            max: (p['max'] as num? ?? 0).toDouble(),
            step: (p['step'] as num? ?? 1).toDouble(),
            tolerance: (p['tol'] as num? ?? 0).toDouble(),
            unit: p['unit'] as String? ?? '',
          );
        }).toList();
    final ranges = {
      for (final p in parameters)
        if (p.kind == LabKind.range) p.id,
    };

    final profiles =
        (json['profiles'] as List)
            .cast<Map<String, dynamic>>()
            .map(
              (p) => LabProfile(
                target: p['target'] as String,
                expect: (p['expect'] as Map<String, dynamic>).map((k, v) {
                  final e = v as Map<String, dynamic>;
                  return MapEntry(
                    k,
                    e.containsKey('values')
                        ? LabExpectation.values(
                          (e['values'] as List).cast<String>().toSet(),
                        )
                        : LabExpectation.range(
                          (e['min'] as num).toDouble(),
                          (e['max'] as num).toDouble(),
                        ),
                  );
                }),
              ),
            )
            .toList();

    final presets =
        (json['presets'] as List)
            .cast<Map<String, dynamic>>()
            .map(
              (p) => LabPreset(
                name: p['name'] as String,
                expected: p['expected'] as String,
                measures: (p['measures'] as Map<String, dynamic>).map(
                  (k, v) => MapEntry(
                    k,
                    ranges.contains(k) ? (v as num).toDouble() : v as Object,
                  ),
                ),
              ),
            )
            .toList();

    return LabData(
      parameters: parameters,
      profiles: profiles,
      presets: presets,
    );
  }
}
