import 'package:flutter/material.dart';
import 'package:nutrisafe_mitra/features/food_scan/presentation/food_scan_report_page.dart';

import 'app/theme/app_theme.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const FoodScanReportPage(),
    ),
  );
}
