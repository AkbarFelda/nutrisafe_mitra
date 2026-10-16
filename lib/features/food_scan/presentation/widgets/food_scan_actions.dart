import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_icon.dart';

class AnalyzeFoodButton extends StatelessWidget {
  const AnalyzeFoodButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    key: const Key('analyze-food'),
    onPressed: isLoading ? null : onPressed,
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(54),
      backgroundColor: const Color(0xFF16A34A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    icon: isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const AppIcon(AppAssets.scannermealIcon, size: 22),
    label: Text(isLoading ? 'Menganalisis...' : 'Mulai Analisis'),
  );
}

class SubmitFoodReportButton extends StatelessWidget {
  const SubmitFoodReportButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    key: const Key('submit-food-report'),
    onPressed: isLoading ? null : onPressed,
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    icon: isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const AppIcon(AppAssets.recentreportIcon, size: 22),
    label: Text(isLoading ? 'Mengirim...' : 'Kirim Laporan Menu'),
  );
}
