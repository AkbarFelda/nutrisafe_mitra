import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_icon.dart';

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
        const AppIcon(AppAssets.problemreportIcon, size: 40),
        const SizedBox(height: 12),
        Text(
          'Belum ada laporan makanan bermasalah',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
