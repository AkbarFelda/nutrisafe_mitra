import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/responsive_content.dart';
import '../data/sample_schools.dart';
import '../domain/school.dart';

const _background = Color(0xFFC2E7FC);
const _header = Color(0xFFCAF1FC);
const _heading = Color(0xFF000769);

class SchoolListPage extends StatelessWidget {
  const SchoolListPage({super.key, this.schools = sampleSchools});

  final List<School> schools;

  void _goBack(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      Navigator.maybePop(context);
    } else if (router.canPop()) {
      router.pop();
    } else {
      router.go('/');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    appBar: AppBar(
      backgroundColor: _header,
      foregroundColor: _heading,
      scrolledUnderElevation: 0,
      toolbarHeight: 68,
      leadingWidth: 60,
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(Icons.arrow_back_ios_new, size: 28),
        onPressed: () => _goBack(context),
      ),
      titleSpacing: 0,
      title: const Text(
        'Daftar Sekolah',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
    body: SafeArea(
      top: false,
      child: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            _SchoolSummary(schools: schools),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.only(left: 5, bottom: 8),
              child: Text(
                'Daftar Sekolah',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            if (schools.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Belum ada sekolah terdaftar',
                  textAlign: TextAlign.center,
                ),
              ),
            for (final school in schools) ...[
              _SchoolCard(school: school),
              const SizedBox(height: 7),
            ],
          ],
        ),
      ),
    ),
  );
}

class _SchoolSummary extends StatelessWidget {
  const _SchoolSummary({required this.schools});

  final List<School> schools;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(13) / 13;
      final width = constraints.maxWidth < 340 * scale
          ? constraints.maxWidth
          : (constraints.maxWidth - 16) / 2;
      return Wrap(
        spacing: 16,
        runSpacing: 10,
        children: [
          SizedBox(
            width: width,
            child: _SummaryCard(
              icon: '🏫',
              title: 'Jumlah Sekolah',
              value: schools.length,
              unit: 'Sekolah',
              color: const Color(0xFF76FFD7),
            ),
          ),
          SizedBox(
            width: width,
            child: _SummaryCard(
              icon: '👨‍🎓',
              title: 'Total Siswa',
              value: schools.fold<int>(
                0,
                (sum, school) => sum + school.students,
              ),
              unit: 'Siswa',
              color: const Color(0xFFFFF9A0),
            ),
          ),
        ],
      );
    },
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String icon;
  final String title;
  final int value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Row(
      children: [
        ExcludeSemantics(
          child: Text(icon, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$value ',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: unit,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SchoolCard extends StatelessWidget {
  const _SchoolCard({required this.school});

  final School school;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFF9FE8F8),
      border: Border.all(color: const Color(0xFFADBDBF)),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Text(
                school.level == SchoolLevel.elementary ? '🏫' : '🏢',
                style: const TextStyle(fontSize: 31),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    school.address,
                    style: const TextStyle(
                      fontSize: 8.5,
                      height: 1.5,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 30,
                    runSpacing: 4,
                    children: [
                      _SchoolCount(
                        icon: AppAssets.manstudentIcon,
                        label: '${school.students} Siswa',
                      ),
                      _SchoolCount(
                        icon: AppAssets.schoolIcon,
                        label: '${school.teachers} Guru',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (school.allergies.isNotEmpty) ...[
          const SizedBox(height: 11),
          LayoutBuilder(
            builder: (context, constraints) {
              final scale = MediaQuery.textScalerOf(context).scale(8.5) / 8.5;
              final columns = constraints.maxWidth >= 300 * scale
                  ? 3
                  : constraints.maxWidth >= 200 * scale
                  ? 2
                  : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 8) / columns;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final allergy in school.allergies)
                    SizedBox(
                      width: width,
                      child: _AllergyCount(allergy: allergy),
                    ),
                ],
              );
            },
          ),
        ],
      ],
    ),
  );
}

class _SchoolCount extends StatelessWidget {
  const _SchoolCount({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppIcon(icon, size: 12),
      const SizedBox(width: 3),
      Flexible(
        child: Text(
          label,
          style: const TextStyle(fontSize: 8.5, color: Colors.black),
        ),
      ),
    ],
  );
}

class _AllergyCount extends StatelessWidget {
  const _AllergyCount({required this.allergy});

  final SchoolAllergy allergy;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (allergy.allergen) {
      SchoolAllergen.peanuts => ('Kacang', const Color(0xFFF00000)),
      SchoolAllergen.eggs => ('Telur', const Color(0xFFFFCB24)),
      SchoolAllergen.milk => ('Susu', const Color(0xFFDC00CF)),
    };
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${allergy.students} Siswa Alergi $label',
            style: const TextStyle(
              fontSize: 8,
              height: 1.25,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
