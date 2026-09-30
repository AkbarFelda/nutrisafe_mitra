import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/food_scan/presentation/food_scan_report_page.dart';

void main() {
  Widget buildPage() =>
      MaterialApp(theme: AppTheme.light, home: const FoodScanReportPage());

  testWidgets('menampilkan aksi scan dan form pelaporan', (tester) async {
    await tester.pumpWidget(buildPage());

    expect(find.text('Scan & Pelaporan Menu'), findsOneWidget);
    expect(find.byKey(const Key('menu-name-field')), findsOneWidget);
    expect(find.text('Buka Kamera'), findsOneWidget);
    expect(find.text('Galeri'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Mulai Analisis'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.text('Lengkapi informasi menu'), findsNothing);
    expect(find.text('Sekolah tujuan'), findsNothing);
    expect(find.text('Kirim Laporan Menu'), findsOneWidget);
  });

  testWidgets('memvalidasi foto sebelum laporan dikirim', (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.enterText(
      find.byKey(const Key('menu-name-field')),
      'Nasi ayam kecap',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -1800));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submit-food-report')));
    await tester.pump();

    expect(
      find.text('Tambahkan foto menu makanan terlebih dahulu.'),
      findsOneWidget,
    );
  });

  testWidgets('tetap responsif pada layar ponsel kecil', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildPage());

    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView), const Offset(0, -1800));
    await tester.pumpAndSettle();
    expect(find.text('Kirim Laporan Menu'), findsOneWidget);
  });
}
