import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/presentation/api_cubit.dart';
import '../../../core/widgets/responsive_content.dart';
import '../data/sppg_dashboard_repository.dart';
import 'widgets/partnership_app_bar.dart';

class SppgDetailPage extends StatelessWidget {
  const SppgDetailPage({super.key, required this.repository});

  final SppgDashboardRepository repository;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ApiCubit<SppgStatus>()..run(repository.getStatus),
    child: Scaffold(
      backgroundColor: AppColors.loginBackground,
      appBar: const PartnershipAppBar(
        title: 'Detail SPPG',
        fallbackRoute: '/partnership/status',
      ),
      body: BlocBuilder<ApiCubit<SppgStatus>, ApiState<SppgStatus>>(
        builder: (context, state) {
          if (state.status == ApiStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final detail = state.data;
          if (detail == null) {
            return Center(child: Text(state.message ?? 'Data gagal dimuat.'));
          }
          return ResponsiveContent(
            maxWidth: 640,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.business_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  detail.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.heading,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _DetailRow(label: 'Status', value: detail.status),
                        const Divider(height: 28),
                        _DetailRow(label: 'Alamat', value: detail.address),
                        const Divider(height: 28),
                        _DetailRow(
                          label: 'Kapasitas produksi',
                          value: '${detail.capacity} porsi/hari',
                        ),
                        const Divider(height: 28),
                        _DetailRow(
                          label: 'Sekolah terhubung',
                          value: '${detail.schoolCount} sekolah',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 130,
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
      Expanded(
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    ],
  );
}
