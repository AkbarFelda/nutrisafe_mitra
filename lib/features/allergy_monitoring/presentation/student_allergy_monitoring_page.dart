import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/presentation/api_cubit.dart';
import '../../partnership/data/sppg_dashboard_repository.dart';
import '../data/sample_allergy_monitoring.dart';
import '../domain/allergy_monitoring.dart';
import 'components/allergy_charts.dart';
import 'components/allergy_section.dart';
import 'components/allergy_summary.dart';
import 'components/school_allergy_card.dart';

class StudentAllergyMonitoringPage extends StatelessWidget {
  const StudentAllergyMonitoringPage({super.key, this.data, this.repository});
  final AllergyMonitoringData? data;
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
      return _buildPage(context, data ?? sampleAllergyMonitoring);
    }
    return BlocProvider(
      create: (_) =>
          ApiCubit<AllergyMonitoringData>()..run(source.getAllergyDashboard),
      child:
          BlocBuilder<
            ApiCubit<AllergyMonitoringData>,
            ApiState<AllergyMonitoringData>
          >(
            builder: (context, state) {
              if (state.status == ApiStatus.loading && state.data == null) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (state.status == ApiStatus.failure && state.data == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Monitoring Alergi Siswa')),
                  body: Center(
                    child: Text(state.message ?? 'Data gagal dimuat.'),
                  ),
                );
              }
              return _buildPage(
                context,
                state.data ?? data ?? sampleAllergyMonitoring,
              );
            },
          ),
    );
  }

  Widget _buildPage(BuildContext context, AllergyMonitoringData monitoring) {
    return Scaffold(
      backgroundColor: const Color(0xFFBFE7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCAF1FC),
        foregroundColor: AppColors.heading,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => _goBack(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          'Monitoring Alergi Siswa',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AllergySummary(data: monitoring),
              const SizedBox(height: 16),
              AllergySection(
                title: 'Jenis Alergi Siswa',
                child: AllergyPieChart(data: monitoring),
              ),
              const SizedBox(height: 16),
              AllergySection(
                title: 'Jumlah Siswa Alergi',
                child: AllergyBarChart(data: monitoring),
              ),
              const SizedBox(height: 16),
              AllergySection(
                title: 'Daftar Sekolah dengan Data Alergi',
                child: Column(
                  children: [
                    if (monitoring.schools.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Belum ada data sekolah',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (var i = 0; i < monitoring.schools.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      SchoolAllergyCard(school: monitoring.schools[i]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
