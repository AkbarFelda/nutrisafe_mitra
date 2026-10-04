import '../../../core/widgets/responsive_content.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/presentation/api_cubit.dart';
import '../data/sppg_dashboard_repository.dart';

import 'sppg_registration_page.dart';
import 'widgets/partnership_app_bar.dart';
import 'widgets/partnership_summary_card.dart';
import 'widgets/sppg_card.dart';
import 'widgets/partnership_registration_button.dart';

class PartnershipStatusPage extends StatelessWidget {
  const PartnershipStatusPage({super.key, this.repository});

  final SppgDashboardRepository? repository;

  @override
  Widget build(BuildContext context) {
    final source = repository;
    if (source == null) return _buildPage(context, null);
    return BlocProvider(
      create: (_) => ApiCubit<SppgStatus>()..run(source.getStatus),
      child: BlocBuilder<ApiCubit<SppgStatus>, ApiState<SppgStatus>>(
        builder: (context, state) {
          if (state.status == ApiStatus.loading && state.data == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.status == ApiStatus.failure && state.data == null) {
            return Scaffold(
              appBar: const PartnershipAppBar(title: 'Status Kemitraan'),
              body: Center(child: Text(state.message ?? 'Data gagal dimuat.')),
            );
          }
          return _buildPage(context, state.data);
        },
      ),
    );
  }

  Widget _buildPage(BuildContext context, SppgStatus? status) {
    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      appBar: const PartnershipAppBar(title: 'Status Kemitraan'),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          maxWidth: 720,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 190,
                        child: Image.asset(
                          AppAssets.bannerpartner,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 16),
                      PartnershipSummaryCard(status: status),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Daftar SPPG',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            AppIcon(AppAssets.buildingIcon, size: 18),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      SppgCard(
                        status: status,
                        onDetail: () {
                          context.push('/partnership/detail');
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              PartnershipRegistrationButton(
                onPressed: () {
                  final router = GoRouter.maybeOf(context);
                  if (router != null) {
                    router.push('/partnership/register');
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SppgRegistrationPage(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
