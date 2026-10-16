import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class FoodIssueEmptyState extends StatelessWidget {
  const FoodIssueEmptyState({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF6FF),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF9DCEF5)),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.assignment_outlined,
          size: 48,
          color: AppColors.primary,
        ),
        const SizedBox(height: 14),
        const Text(
          'Belum ada laporan makanan bermasalah',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.heading,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Laporan dari sekolah akan muncul di halaman ini.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
      ],
    ),
  );
}
