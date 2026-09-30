import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/food_issue.dart';

class FoodIssueCard extends StatelessWidget {
  const FoodIssueCard({super.key, required this.report, required this.onTap});

  final FoodIssue report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFADD6E8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.school,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.problem,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.heading,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Dilaporkan oleh ${report.reporter}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                foodIssueDateTime(report.date),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
