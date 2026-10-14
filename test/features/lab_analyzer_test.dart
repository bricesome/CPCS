import 'package:cpcs/features/lab/domain/entities/lab.dart';
import 'package:cpcs/features/lab/domain/services/lab_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_data.dart';

void main() {
  group('calcul du score', () {
    const lab = LabData(
      parameters: [
        LabParameter(
          id: 'a',
          label: 'A',
          explanation: '',
          kind: LabKind.choice,
          weight: 3,
          options: [
            LabOption(id: 'x', label: 'X', explanation: ''),
            LabOption(id: 'y', label: 'Y', explanation: ''),
          ],
        ),
        LabParameter(
          id: 'b',
          label: 'B',
          explanation: '',
          kind: LabKind.range,
          weight: 2,
          min: 0,
          max: 10,
          tolerance: 1,
        ),
      ],
      profiles: [
        LabProfile(
          target: 'P1',
          expect: {
            'a': LabExpectation.values({'x'}),
            'b': LabExpectation.range(5, 6),
          },
        ),
        LabProfile(
          target: 'P2',
          expect: {
            'a': LabExpectation.values({'y'}),
          },
        ),
        LabProfile(
          target: 'P3',
          expect: {
            'a': LabExpectation.values({'x'}),
          },
        ),
      ],
    );

    LabResult of(List<LabResult> r, String t) =>
        r.firstWhere((e) => e.target == t);

    test('aucune mesure : aucun résultat', () {
      expect(LabAnalyzer.analyze(lab, const {}), isEmpty);
    });

    test('valeur proche = demi-point, couverture prise en compte', () {
      final r = LabAnalyzer.analyze(lab, const {'a': 'x', 'b': 6.5});
      final p1 = of(r, 'P1');
      expect(p1.earnedPoints, 4);
      expect(p1.consideredWeight, 5);
      expect(p1.agreement, closeTo(0.8, 1e-12));
      expect(p1.coverage, 1);
      expect(p1.score, closeTo(0.8, 1e-12));
      expect(
        p1.elements.firstWhere((e) => e.parameter.id == 'b').verdict,
        LabVerdict.near,
      );
      final p3 = of(r, 'P3');
      expect(p3.agreement, 1);
      expect(p3.coverage, closeTo(0.6, 1e-12));
      expect(p3.score, closeTo(0.84, 1e-12));
      expect(of(r, 'P2').score, 0);
      expect(r.map((e) => e.target), ['P3', 'P1', 'P2']);
    });

    test('valeur hors tolérance = contradiction', () {
      final r = LabAnalyzer.analyze(lab, const {'a': 'x', 'b': 8});
      final p1 = of(r, 'P1');
      expect(p1.earnedPoints, 3);
      expect(p1.score, closeTo(0.6, 1e-12));
      expect(
        p1.elements.firstWhere((e) => e.parameter.id == 'b').verdict,
        LabVerdict.contradiction,
      );
    });

    test('bornes incluses et limite exacte de tolérance', () {
      for (final b in [5.0, 6.0]) {
        expect(of(LabAnalyzer.analyze(lab, {'b': b}), 'P1').score, 1);
      }
      expect(of(LabAnalyzer.analyze(lab, const {'b': 7.0}), 'P1').score, 0.5);
      expect(of(LabAnalyzer.analyze(lab, const {'b': 4.0}), 'P1').score, 0.5);
      expect(of(LabAnalyzer.analyze(lab, const {'b': 7.01}), 'P1').score, 0);
    });

    test(
      'ex æquo : le profil le mieux expliqué par les mesures passe devant',
      () {
        final r = LabAnalyzer.analyze(lab, const {'a': 'x'});
        expect(r.map((e) => e.target).take(2), ['P3', 'P1']);
      },
    );

    test('paramètre inconnu ignoré', () {
      final r = LabAnalyzer.analyze(lab, const {'zz': 'x', 'a': 'y'});
      expect(r.first.target, 'P2');
      expect(r.first.providedWeight, 3);
    });
  });

  group('référentiel CPCS', () {
    final data = loadTestClassification();
    final lab = data.lab;

    test('profils cohérents avec la classification et les paramètres', () {
      final sousClasses =
          data.units
              .where((u) => u.code.split('.').length == 2)
              .map((u) => u.id)
              .toSet();
      expect(lab.profiles.map((p) => p.target).toSet(), sousClasses);
      expect(lab.parameters.length, 13);
      for (final p in lab.profiles) {
        for (final e in p.expect.entries) {
          final param = lab.parameter(e.key);
          expect(param, isNotNull, reason: '${p.target}/${e.key}');
          if (param!.kind == LabKind.choice) {
            expect(e.value.isRange, isFalse);
            for (final v in e.value.values) {
              expect(param.option(v), isNotNull, reason: '${p.target}/$v');
            }
          } else {
            expect(e.value.isRange, isTrue);
            expect(e.value.min! <= e.value.max!, isTrue);
            expect(e.value.min! >= param.min, isTrue);
            expect(e.value.max! <= param.max, isTrue);
          }
        }
      }
    });

    test('chaque échantillon d\'exemple donne le sol attendu à 100 %', () {
      expect(lab.presets, isNotEmpty);
      for (final preset in lab.presets) {
        final r = LabAnalyzer.analyze(lab, preset.measures);
        expect(r.first.target, preset.expected, reason: preset.name);
        expect(r.first.percent, 100, reason: preset.name);
        expect(r[1].score < r.first.score, isTrue, reason: preset.name);
      }
    });

    test('un profil type est reconnu comme lui-même', () {
      for (final p in lab.profiles) {
        final measures = <String, Object>{
          for (final e in p.expect.entries)
            e.key:
                e.value.isRange
                    ? (e.value.min! + e.value.max!) / 2
                    : e.value.values.first,
        };
        final r = LabAnalyzer.analyze(lab, measures);
        expect(r.first.target, p.target);
        expect(r.first.score, 1);
      }
    });

    test('exemple du guide : pH 6 oriente vers X.1', () {
      final preset = lab.presets.firstWhere((p) => p.expected == 'X.3');
      final r = LabAnalyzer.analyze(lab, {...preset.measures, 'ph': 6.0});
      expect(r.first.target, 'X.1');
    });

    test('scores toujours entre 0 et 1, résultats triés', () {
      final r = LabAnalyzer.analyze(lab, const {
        'eau': 'permanent',
        'horizons': 'alteration',
        'ph': 4.0,
        'effervescence': 'forte',
        'ce': 15.0,
      });
      for (var i = 0; i < r.length; i++) {
        expect(r[i].score, inInclusiveRange(0, 1));
        if (i > 0) expect(r[i].score <= r[i - 1].score + 1e-9, isTrue);
      }
    });

    test('guide et crédits', () {
      for (final id in [
        'classification',
        'croisement',
        'comparer',
        'cle',
        'labo',
        'apprendre',
      ]) {
        expect(data.guideSection(id), isNotNull, reason: id);
      }
      expect(data.credits.map((c) => '${c.role} : ${c.name}'), [
        'Auteur : Professeur EDMOND HIEN',
        'Contributeur : NANAWENDIN YAMEOGO',
        'Concepteur : NIBENAON SOME',
      ]);
    });
  });
}
