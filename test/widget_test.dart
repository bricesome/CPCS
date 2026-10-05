import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nana_doc/core/service_locator.dart' as di;
import 'package:nana_doc/features/classification/data/datasources/user_prefs_local_data_source.dart';
import 'package:nana_doc/main.dart';

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

    await tester.pumpWidget(const NanaDocApp());
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

    await tester.pumpWidget(const NanaDocApp());
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
}
