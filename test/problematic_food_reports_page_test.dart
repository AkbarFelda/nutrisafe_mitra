import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/food_issues/domain/food_issue.dart';
import 'package:nutrisafe_mitra/features/food_issues/presentation/problematic_food_reports_page.dart';

Widget app({List<FoodIssue>? reports, double scale = 1}) => MaterialApp(
  theme: AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: ProblematicFoodReportsPage(reports: reports),
);

void main() {
  testWidgets('opens selected report and returns to report list', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.ensureVisible(find.text('Makanan berbau tidak sedap'));
    await tester.tap(find.text('Makanan berbau tidak sedap'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Laporan'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('22 Maret 2026 \u2022 12.15'), findsOneWidget);
    expect(find.text('Sayur capcay'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ketuk foto untuk memperbesar'),
      150,
    );
    expect(find.byType(Image), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Makanan berbau tidak sedap'), findsOneWidget);
    expect(find.text('LM-003'), findsNothing);
  });

  testWidgets('empty input does not display demo reports', (tester) async {
    await tester.pumpWidget(app(reports: []));
    expect(find.text('Belum ada laporan makanan bermasalah'), findsOneWidget);
    expect(
      find.text('Laporan dari sekolah akan muncul di halaman ini.'),
      findsOneWidget,
    );
    expect(find.text('LM-003'), findsNothing);
  });

  for (final scenario in [
    (size: const Size(320, 568), scale: 1.0),
    (size: const Size(320, 568), scale: 2.0),
    (size: const Size(844, 390), scale: 1.0),
    (size: const Size(568, 320), scale: 2.0),
    (size: const Size(1200, 900), scale: 1.5),
  ]) {
    testWidgets('reports fit ${scenario.size} with scale ${scenario.scale}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(scenario.size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(app(scale: scenario.scale));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Kemasan susu bocor'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Kemasan susu bocor').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
