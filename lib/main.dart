import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';

import 'package:nutrisafe_mitra/features/food_report/presentation/food_report_history_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(body: const FoodReportHistoryPage()),
    ),
  );
}
