import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/food_report/domain/food_report.dart';
import 'package:nutrisafe_mitra/features/food_report/presentation/food_report_history_page.dart';

final reports = [
  FoodReport(
    date: DateTime(2025, 3, 23),
    school: 'Sekolah Lama',
    address: 'Alamat lama',
    portions: 10,
  ),
  FoodReport(
    date: DateTime(2026, 3, 23),
    school: 'Sekolah Baru',
    address: 'Alamat baru',
    portions: 20,
    status: FoodReportStatus.received,
    distributedPortions: 20,
    studentsWithAllergies: 2,
    allergies: const [FoodReportAllergy(name: 'Telur', students: 2)],
    menuItems: const [
      FoodReportMenuItem(
        name: 'Menu Pengganti (Tanpa Telur)',
        category: 'Khusus Siswa Alergi',
        portions: 2,
      ),
    ],
  ),
];

Widget app({List<FoodReport>? data, double scale = 1}) => MaterialApp(
  theme: AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: FoodReportHistoryPage(reports: data ?? reports),
);

void main() {
  testWidgets('month filter changes reports without search or all periods', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Semua periode'), findsNothing);
    expect(find.text('Sekolah Baru'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('April').last);
    await tester.pumpAndSettle();
    expect(find.text('Belum ada laporan bulan ini'), findsOneWidget);
    expect(find.text('Sekolah Baru'), findsNothing);
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maret').last);
    await tester.pumpAndSettle();
    expect(find.text('Sekolah Baru'), findsOneWidget);
  });

  testWidgets('detail opens selected report page and returns to history', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.ensureVisible(find.text('Detail').first);
    await tester.tap(find.text('Detail').first);
    await tester.pumpAndSettle();
    expect(find.text('Detail Riwayat Laporan Sekolah Baru'), findsOneWidget);
    expect(find.text('Total Porsi'), findsOneWidget);
    expect(find.text('20'), findsNWidgets(2));
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('23 Maret 2026'), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Riwayat Laporan Sekolah Baru'), findsNothing);
  });

  testWidgets('empty real history does not display sample reports', (
    tester,
  ) async {
    await tester.pumpWidget(app(data: []));
    expect(find.text('Belum ada laporan makanan'), findsOneWidget);
    expect(find.text('Data contoh'), findsNothing);
    expect(find.text('Detail'), findsNothing);
  });

  const scenarios = [
    (name: 'small phone', size: Size(320, 568), scale: 1.0),
    (name: 'small phone large text', size: Size(320, 568), scale: 2.0),
    (name: 'phone', size: Size(390, 844), scale: 1.0),
    (name: 'landscape', size: Size(844, 390), scale: 1.0),
    (name: 'landscape large text', size: Size(568, 320), scale: 2.0),
    (name: 'tablet', size: Size(1200, 900), scale: 1.5),
  ];
  for (final scenario in scenarios) {
    testWidgets(
      '${scenario.name}: history, filter, and detail are responsive',
      (tester) async {
        await tester.binding.setSurfaceSize(scenario.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          app(data: [reports.last], scale: scenario.scale),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DropdownButton<int>));
        await tester.pumpAndSettle();
        await Scrollable.ensureVisible(
          tester.element(find.text('April').last),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('April').last);
        await tester.pumpAndSettle();
        expect(find.text('Belum ada laporan bulan ini'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byType(DropdownButton<int>));
        await tester.pumpAndSettle();
        await Scrollable.ensureVisible(
          tester.element(find.text('Maret').last),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Maret').last);
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Detail'),
          200,
          scrollable: find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Detail'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Detail').first);
        await tester.pumpAndSettle();
        expect(
          find.text('Detail Riwayat Laporan Sekolah Baru'),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('Foto Dokumentasi'));
        await tester.pumpAndSettle();
        expect(find.text('Foto Dokumentasi').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Kembali'));
        await tester.pumpAndSettle();
        expect(find.byType(FoodReportHistoryPage), findsOneWidget);
      },
    );
  }
}
