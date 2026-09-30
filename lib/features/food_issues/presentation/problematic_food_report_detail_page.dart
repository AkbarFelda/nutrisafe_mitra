import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';
import '../domain/food_issue.dart';
import 'components/food_issue_information.dart';
import 'components/food_issue_description.dart';
import 'components/food_issue_evidence.dart';

class ProblematicFoodReportDetailPage extends StatelessWidget {
  const ProblematicFoodReportDetailPage({super.key, required this.report});

  final FoodIssue report;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.loginBackground,
    appBar: AppBar(
      backgroundColor: const Color(0xFFCAF1FC),
      foregroundColor: AppColors.heading,
      scrolledUnderElevation: 0,
      title: const Text(
        'Detail Laporan',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    body: SafeArea(
      top: false,
      child: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              report.school,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.problem,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 20),
            FoodIssueInformation(report: report),
            FoodIssueDescription(report: report),
            FoodIssueEvidence(report: report),
          ],
        ),
      ),
    ),
  );
}
