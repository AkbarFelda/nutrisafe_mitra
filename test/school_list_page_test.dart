import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/schools/data/sample_schools.dart';
import 'package:nutrisafe_mitra/features/schools/domain/school.dart';
import 'package:nutrisafe_mitra/features/schools/presentation/school_list_page.dart';

Widget app({List<School> schools = sampleSchools, double scale = 1}) =>
    MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: SchoolListPage(schools: schools),
    );

void main() {
  testWidgets('sample schools match reference and total 527 students', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    expect(find.text('2 Sekolah', findRichText: true), findsOneWidget);
    expect(find.text('527 Siswa', findRichText: true), findsOneWidget);
    expect(find.text('SDN 1 Subang'), findsOneWidget);
    expect(find.text('SMPN 1 Subang'), findsOneWidget);
    expect(find.text('187 Siswa'), findsOneWidget);
    expect(find.text('340 Siswa'), findsOneWidget);
    expect(find.text('9 Guru'), findsOneWidget);
    expect(find.text('20 Guru'), findsOneWidget);
    expect(find.text('0 Siswa Alergi Susu'), findsOneWidget);
    expect(find.text('4 Siswa Alergi Susu'), findsOneWidget);
  });

  testWidgets('summary derives from supplied schools and handles empty data', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        schools: const [
          School(
            name: 'Sekolah Uji',
            address: 'Alamat Uji',
            level: SchoolLevel.elementary,
            students: 42,
            teachers: 3,
          ),
        ],
      ),
    );
    expect(find.text('1 Sekolah', findRichText: true), findsOneWidget);
    expect(find.text('42 Siswa', findRichText: true), findsWidgets);
    expect(find.text('SDN 1 Subang'), findsNothing);
    await tester.pumpWidget(app(schools: const []));
    expect(find.text('0 Sekolah', findRichText: true), findsOneWidget);
    expect(find.text('0 Siswa', findRichText: true), findsOneWidget);
    expect(find.text('Tidak ada sekolah yang tersedia'), findsOneWidget);
  });

  for (final scenario in [
    (size: const Size(410, 875), scale: 1.0),
    (size: const Size(320, 568), scale: 1.0),
    (size: const Size(320, 568), scale: 2.0),
    (size: const Size(844, 390), scale: 1.0),
    (size: const Size(568, 320), scale: 2.0),
    (size: const Size(1200, 900), scale: 1.5),
  ]) {
    testWidgets(
      'school list fits ${scenario.size} at ${scenario.scale} text scale',
      (tester) async {
        await tester.binding.setSurfaceSize(scenario.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(app(scale: scenario.scale));
        await tester.pumpAndSettle();
        final availableSchoolList = find.descendant(
          of: find.byType(ListView).first,
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          find.text('4 Siswa Alergi Susu'),
          150,
          scrollable: availableSchoolList,
        );
        await tester.pumpAndSettle();
        expect(find.text('4 Siswa Alergi Susu').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('back returns to previous page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SchoolListPage()),
              ),
              child: const Text('Buka sekolah'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Buka sekolah'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Buka sekolah'), findsOneWidget);
    expect(find.byType(SchoolListPage), findsNothing);
  });
}
