import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class FoodIssueEmptyState extends StatelessWidget {
  const FoodIssueEmptyState({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.assignment_turned_in_outlined,
          size: 40,
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        Text(
          'Belum ada laporan makanan bermasalah',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
