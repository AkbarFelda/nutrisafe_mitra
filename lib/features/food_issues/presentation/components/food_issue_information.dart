import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/food_issue.dart';
import 'food_issue_section.dart';
import 'food_issue_info_row.dart';

class FoodIssueInformation extends StatelessWidget {
  const FoodIssueInformation({super.key, required this.report});
  final FoodIssue report;
  @override
  Widget build(BuildContext context) => FoodIssueSection(
    title: 'Informasi Laporan',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FoodIssueInfoRow(
          AppAssets.recentreportIcon,
          'Tanggal pelaporan',
          foodIssueDateTime(report.date),
        ),
        const Divider(height: 28),
        FoodIssueInfoRow(AppAssets.userIcon, 'Pelapor', report.reporter),
        const SizedBox(height: 16),
        FoodIssueInfoRow(AppAssets.schoolIcon, 'Sekolah', report.school),
      ],
    ),
  );
}
