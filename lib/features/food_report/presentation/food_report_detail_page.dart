import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';
import '../domain/food_report.dart';

class FoodReportDetailPage extends StatelessWidget {
  const FoodReportDetailPage({super.key, required this.report});

  final FoodReport report;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.loginBackground,
    appBar: AppBar(
      backgroundColor: AppColors.loginBackground,
      scrolledUnderElevation: 0,
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.heading),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        'Detail Riwayat Laporan',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.heading,
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: ResponsiveContent(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Detail Riwayat Laporan "${report.school}"',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        foodReportDate(report.date),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        report.school,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(report.address),
                      const Divider(height: 32),
                      Text(
                        'Jumlah porsi: ${report.portions}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
