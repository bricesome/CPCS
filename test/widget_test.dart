import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cpcs/core/service_locator.dart' as di;
import 'package:cpcs/features/classification/data/datasources/user_prefs_local_data_source.dart';
import 'package:cpcs/main.dart';

import 'helpers/test_data.dart';

void main() {
  setUp(() async {
    await di.sl.reset();
    await di.init(
      prefs: InMemoryUserPrefsLocalDataSource(),
      assets: FileAssetDataSource(),
    );
  });

  testWidgets('affiche la hiérarchie puis ouvre une fiche', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CPCSApp());
    await tester.pumpAndSettle();

    expect(find.text('Sols minéraux bruts'), findsOneWidget);
    await tester.tap(find.text('Vertisols'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Vertisols topomorphes'), findsOneWidget);

    await tester.tap(find.byTooltip('Ouvrir la fiche').at(2));
    await tester.pumpAndSettle();
    expect(find.text('Critères de croisement'), findsOneWidget);
  });

  testWidgets('croisement et clé de détermination', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CPCSApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Croisement').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('sol(s)'), findsOneWidget);

    await tester.tap(find.text('Clé').first);
    await tester.pumpAndSettle();
    expect(find.text('Question 1'), findsOneWidget);
    await tester.tap(find.text('Non, ou seulement en profondeur'));
    await tester.pumpAndSettle();
    expect(find.text('Question 2'), findsOneWidget);
  });

  testWidgets('labo, guide et crédits', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CPCSApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Labo').first);
    await tester.pumpAndSettle();
    expect(find.text('Analyser (0)'), findsOneWidget);
    await tester.tap(find.text('Charger un échantillon d\'exemple'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sol rouge profond de forêt tropicale'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lab-best')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('lab-best')),
        matching: find.text('100 %'),
      ),
      findsOneWidget,
    );
    expect(find.text('Analyser (7)'), findsOneWidget);

    await tester.tap(find.byTooltip('Guide : Labo'));
    await tester.pumpAndSettle();
    expect(find.text('Guide · Labo'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apprendre').first);
    await tester.pumpAndSettle();
    expect(find.text('Comparer'), findsWidgets);
    await tester.tap(find.text('À propos'));
    await tester.pumpAndSettle();
    expect(find.text('Professeur EDMOND HIEN'), findsOneWidget);
    expect(find.text('NANAWENDIN YAMEOGO'), findsOneWidget);
    expect(find.text('NIBENAON SOME'), findsOneWidget);
  });
}
