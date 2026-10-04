import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/presentation/api_cubit.dart';
import '../../../core/error/app_failure.dart';
import '../../partnership/data/sppg_dashboard_repository.dart';
import '../data/sample_schools.dart';
import '../domain/school.dart';

const _background = Color(0xFFC2E7FC);
const _header = Color(0xFFCAF1FC);
const _heading = Color(0xFF000769);

class SchoolListPage extends StatelessWidget {
  const SchoolListPage({
    super.key,
    this.schools = sampleSchools,
    this.repository,
  });

  final List<School> schools;
  final SppgDashboardRepository? repository;

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
  Widget build(BuildContext context) {
    final source = repository;
    if (source == null) {
      return _buildPage(
        context,
        SchoolDirectory(available: schools, assigned: const []),
      );
    }
    return BlocProvider(
      create: (_) =>
          ApiCubit<SchoolDirectory>()..run(source.getSchoolDirectory),
      child: BlocBuilder<ApiCubit<SchoolDirectory>, ApiState<SchoolDirectory>>(
        builder: (context, state) {
          if (state.status == ApiStatus.loading && state.data == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.status == ApiStatus.failure && state.data == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Daftar Sekolah')),
              body: Center(child: Text(state.message ?? 'Data gagal dimuat.')),
            );
          }
          return _buildPage(
            context,
            state.data ??
                SchoolDirectory(available: schools, assigned: const []),
          );
        },
      ),
    );
  }

  Widget _buildPage(BuildContext context, SchoolDirectory directory) {
    final selected = <int>{};
    var assigning = false;
    return StatefulBuilder(
      builder: (context, setLocalState) => DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _header,
            foregroundColor: _heading,
            scrolledUnderElevation: 0,
            leading: IconButton(
              tooltip: 'Kembali',
              icon: const Icon(Icons.arrow_back_ios_new, size: 28),
              onPressed: () => _goBack(context),
            ),
            title: const Text(
              'Daftar Sekolah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            bottom: const TabBar(
              labelColor: _heading,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Tersedia'),
                Tab(text: 'Terhubung'),
              ],
            ),
          ),
          body: SafeArea(
            top: false,
            child: ResponsiveContent(
              child: TabBarView(
                children: [
                  _schoolList(
                    schools: directory.available,
                    emptyMessage: 'Tidak ada sekolah yang tersedia',
                    children: [
                      for (final school in directory.available) ...[
                        _SchoolCard(
                          school: school,
                          selected:
                              school.id != null && selected.contains(school.id),
                          onSelected: school.id == null
                              ? null
                              : (checked) => setLocalState(() {
                                  checked
                                      ? selected.add(school.id!)
                                      : selected.remove(school.id);
                                }),
                        ),
                        const SizedBox(height: 7),
                      ],
                      if (repository != null &&
                          directory.available.any(
                            (school) => school.id != null,
                          ))
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: FilledButton.icon(
                            key: const Key('assign-schools-button'),
                            onPressed: assigning || selected.isEmpty
                                ? null
                                : () async {
                                    setLocalState(() => assigning = true);
                                    try {
                                      await repository!.assignSchools(
                                        selected.toList(),
                                      );
                                      if (!context.mounted) return;
                                      await context
                                          .read<ApiCubit<SchoolDirectory>>()
                                          .run(repository!.getSchoolDirectory);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Sekolah berhasil dihubungkan.',
                                              ),
                                            ),
                                          );
                                    } catch (error) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppFailure.from(error).message,
                                              ),
                                            ),
                                          );
                                    } finally {
                                      if (context.mounted) {
                                        setLocalState(() => assigning = false);
                                      }
                                    }
                                  },
                            icon: assigning
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.link_rounded),
                            label: const Text('Hubungkan Sekolah Terpilih'),
                          ),
                        ),
                    ],
                  ),
                  _schoolList(
                    schools: directory.assigned,
                    emptyMessage: 'Belum ada sekolah yang terhubung',
                    children: [
                      for (final school in directory.assigned) ...[
                        _SchoolCard(school: school),
                        const SizedBox(height: 7),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _schoolList({
    required List<School> schools,
    required String emptyMessage,
    required List<Widget> children,
  }) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
    children: [
      _SchoolSummary(schools: schools),
      const SizedBox(height: 18),
      if (schools.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(emptyMessage, textAlign: TextAlign.center),
        ),
      ...children,
    ],
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
  const _SchoolCard({
    required this.school,
    this.selected = false,
    this.onSelected,
  });

  final School school;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFD9F4FF) : const Color(0xFF9FE8F8),
      border: Border.all(
        color: selected ? AppColors.primary : const Color(0xFFADBDBF),
        width: selected ? 2 : 1,
      ),
      borderRadius: BorderRadius.circular(10),
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
            if (onSelected != null)
              Column(
                children: [
                  Checkbox(
                    key: Key('school-checkbox-${school.id}'),
                    value: selected,
                    onChanged: (value) => onSelected!(value ?? false),
                    activeColor: AppColors.primary,
                  ),
                  if (selected)
                    const Text(
                      'Terpilih',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
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
        if (school.allergies.isEmpty && school.allergyTypes.isNotEmpty) ...[
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final allergy in school.allergyTypes)
                Chip(
                  avatar: const CircleAvatar(
                    radius: 6,
                    backgroundColor: Color(0xFFF00000),
                  ),
                  label: Text('Alergi $allergy'),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                  backgroundColor: Colors.white.withValues(alpha: 0.72),
                ),
            ],
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
