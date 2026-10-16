import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/features/allergy_monitoring/domain/allergy_monitoring.dart';
import 'package:nutrisafe_mitra/features/allergy_monitoring/data/sample_allergy_monitoring.dart';
import 'package:nutrisafe_mitra/features/allergy_monitoring/presentation/student_allergy_monitoring_page.dart';

void main() {
  test('counts unique students separately from allergy occurrences', () {
    final data = AllergyMonitoringData([
      SchoolAllergyData(
        name: 'Sekolah',
        students: 10,
        studentAllergies: [
          {StudentAllergy.peanut, StudentAllergy.milk},
          {StudentAllergy.egg},
        ],
      ),
    ]);
    expect(data.allergicStudents, 2);
    expect(data.totalAllergies, 3);
    expect(data.types.length, 3);
    expect(sampleAllergyMonitoring.allergicStudents, 18);
    expect(sampleAllergyMonitoring.count(StudentAllergy.peanut), 10);
    expect(sampleAllergyMonitoring.count(StudentAllergy.egg), 8);
    expect(sampleAllergyMonitoring.count(StudentAllergy.milk), 0);
    expect(sampleAllergyMonitoring.schools[0].students, 196);
    expect(sampleAllergyMonitoring.schools[1].students, 360);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
    const Size(1200, 900),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('fits $size at text scale $scale', (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const StudentAllergyMonitoringPage(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('18'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(find.text('Jumlah Siswa Alergi'), 200);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(find.text('SMPN 1 Subang'), 200);
        await tester.pumpAndSettle();
        expect(find.text('2,50% siswa alergi'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('empty data renders without demo values or division errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StudentAllergyMonitoringPage(data: AllergyMonitoringData([])),
      ),
    );
    expect(find.text('0'), findsWidgets);
    expect(find.text('18'), findsNothing);
    expect(find.text('Belum ada data alergi siswa'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Belum ada data sekolah'), 200);
    expect(tester.takeException(), isNull);
  });
}
