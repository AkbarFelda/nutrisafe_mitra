import 'package:flutter/material.dart';
import 'package:nutrisafe_mitra/features/food_issues/presentation/problematic_food_reports_page.dart';

import 'app/theme/app_theme.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ProblematicFoodReportsPage(),
    ),
  );
}
