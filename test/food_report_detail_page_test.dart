import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/food_report/domain/food_report.dart';
import 'package:nutrisafe_mitra/features/food_report/presentation/food_report_detail_page.dart';

Widget app(FoodReport report) => MaterialApp(
  theme: AppTheme.light,
  home: FoodReportDetailPage(report: report),
);

void main() {
  testWidgets(
    'detail renders supplied status, distribution, allergies and menu',
    (tester) async {
      final report = FoodReport(
        date: DateTime(2026, 9, 25),
        school: 'Sekolah Uji',
        address: 'Alamat Uji',
        portions: 80,
        status: FoodReportStatus.pending,
        distributedPortions: 60,
        studentsWithAllergies: 3,
        allergies: const [FoodReportAllergy(name: 'Susu', students: 3)],
        menuItems: const [
          FoodReportMenuItem(
            name: 'Ikan Panggang',
            category: 'Protein',
            portions: 57,
          ),
        ],
        documentationPhotos: const ['assets/images/dummy_stale_capcay.png'],
      );
      await tester.pumpWidget(app(report));
      expect(find.text('Menunggu'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('75% Selesai'), findsOneWidget);
      expect(find.text('3 Siswa Alergi Susu'), findsOneWidget);
      await tester.ensureVisible(find.text('Ikan Panggang'));
      expect(find.text('Ikan Panggang').hitTestable(), findsOneWidget);
      expect(find.text('57 Porsi'), findsOneWidget);
      expect(find.text('Nasi Putih'), findsNothing);
      expect(find.text('Diterima'), findsNothing);
      await tester.ensureVisible(find.text('Foto Dokumentasi'));
      expect(find.byType(Image), findsOneWidget);
    },
  );

  testWidgets('missing detail data does not fabricate sample values', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        FoodReport(
          date: DateTime(2026, 9, 25),
          school: 'Sekolah Uji',
          address: 'Alamat Uji',
          portions: 80,
        ),
      ),
    );
    expect(find.text('Diterima'), findsNothing);
    expect(find.text('100% Selesai'), findsNothing);
    expect(find.text('Belum tersedia'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
    expect(find.text('Nasi Putih'), findsNothing);
    expect(find.textContaining('Siswa Alergi Kacang'), findsNothing);
  });

  test('distribution percentage handles absent data and zero portions', () {
    FoodReport report({int portions = 80, int? distributed}) => FoodReport(
      date: DateTime(2026, 9, 25),
      school: 'Sekolah Uji',
      address: 'Alamat Uji',
      portions: portions,
      distributedPortions: distributed,
    );
    expect(report().distributionPercentage, isNull);
    expect(report(portions: 0, distributed: 0).distributionPercentage, isNull);
    expect(report(distributed: 0).distributionPercentage, 0);
    expect(report(distributed: 60).distributionPercentage, 75);
    expect(report(distributed: 80).distributionPercentage, 100);
  });
}
