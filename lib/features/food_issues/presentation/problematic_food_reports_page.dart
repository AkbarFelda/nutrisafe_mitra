import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';
import 'problematic_food_report_detail_page.dart';
import 'components/food_issue_card.dart';
import 'components/food_issue_empty_state.dart';
import '../data/sample_food_issues.dart';
import '../domain/food_issue.dart';

class ProblematicFoodReportsPage extends StatelessWidget {
  const ProblematicFoodReportsPage({super.key, this.reports});

  final List<FoodIssue>? reports;

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
    final reports = this.reports ?? sampleFoodIssues;
    final sorted = reports.toList()..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      backgroundColor: AppColors.loginBackground,
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
          'Laporan Makanan Bermasalah',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (sorted.isEmpty) const FoodIssueEmptyState(),
              for (final report in sorted) ...[
                FoodIssueCard(
                  key: ValueKey(report.id),
                  report: report,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ProblematicFoodReportDetailPage(report: report),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
