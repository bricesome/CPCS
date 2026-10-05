import 'package:flutter_test/flutter_test.dart';
import 'package:nana_doc/features/classification/domain/entities/classification.dart';
import 'package:nana_doc/features/classification/domain/entities/soil_unit.dart';
import 'package:nana_doc/features/classification/domain/services/cross_filter.dart';

import '../helpers/test_data.dart';

void main() {
  late Classification data;

  setUpAll(() => data = loadTestClassification());

  test('contient les 12 classes et 4 niveaux', () {
    expect(data.roots.length, 12);
    expect(data.levels.length, 4);
    expect(data.roots.first.name, 'Sols minéraux bruts');
    expect(data.roots[2].name, 'Vertisols');
  });

  test('chaque unité a un parent existant et un niveau cohérent', () {
    for (final u in data.units) {
      if (u.parentId == null) {
        expect(u.level, SoilLevelId.classe);
      } else {
        final parent = data.unit(u.parentId!);
        expect(parent, isNotNull, reason: u.id);
        expect(u.level.index, greaterThan(parent!.level.index));
      }
    }
  });

  test('toutes les valeurs de critères sont déclarées', () {
    for (final u in data.units) {
      for (final e in u.criteria.entries) {
        final c = data.criterion(e.key);
        expect(c, isNotNull, reason: '${u.id} ${e.key}');
        for (final v in e.value) {
          expect(c!.value(v), isNotNull, reason: '${u.id} ${e.key}=$v');
        }
      }
    }
  });

  test('les critères sont hérités puis surchargés', () {
    final vertisolGroup = data.unit('III.1.1')!;
    expect(vertisolGroup.criteria['processus'], {'vertisolisation'});
    expect(
      vertisolGroup.criteria['topographie'],
      containsAll(['depression', 'plaine_alluviale']),
    );
    final hydromorphe = data
        .childrenOf('III.1.1')
        .firstWhere((u) => u.name == 'Hydromorphe');
    expect(hydromorphe.criteria['drainage'], {'temporaire'});
    expect(hydromorphe.criteria['processus'], {'vertisolisation'});
  });

  test('le croisement combine ET entre critères et OU entre valeurs', () {
    final results = CrossFilter.apply(
      data,
      selection: {
        'processus': {'vertisolisation', 'andosolisation'},
      },
      levels: {SoilLevelId.classe},
    );
    expect(
      results.map((m) => m.unit.name),
      containsAll(['Vertisols', 'Andosols']),
    );
    expect(results.length, 2);

    final crossed = CrossFilter.apply(
      data,
      selection: {
        'processus': {'ferruginisation'},
        'climat': {'sahelien'},
      },
      levels: {SoilLevelId.groupe},
    );
    expect(crossed, isNotEmpty);
    expect(crossed.every((m) => m.unit.code.startsWith('IX.2')), isTrue);
  });

  test('les valeurs joker donnent des résultats compatibles', () {
    final results = CrossFilter.apply(
      data,
      selection: {
        'climat': {'sahelien'},
        'processus': {'hydromorphie'},
      },
      levels: {SoilLevelId.classe},
    );
    final hydro = results.firstWhere((m) => m.unit.code == 'XI');
    expect(hydro.isExact, isFalse);
  });

  test('la recherche ignore les accents', () {
    final results = CrossFilter.apply(
      data,
      selection: const {},
      query: 'MINERAUX bruts',
    );
    expect(results.first.unit.code, 'I');
  });

  test('la matrice compte les croisements', () {
    final m = CrossFilter.matrix(
      data,
      rowCriterion: 'processus',
      columnCriterion: 'climat',
      level: SoilLevelId.groupe,
    );
    expect(m['ferruginisation']?['sahelien'], greaterThan(0));
  });

  test('la clé de détermination mène toujours à une classe existante', () {
    for (final q in data.keyQuestions) {
      for (final o in q.options) {
        if (o.isResult) {
          expect(data.unit(o.resultId)?.level, SoilLevelId.classe);
        } else {
          expect(data.keyQuestion(o.target), isNotNull);
        }
      }
    }
  });
}
