import 'package:flutter/material.dart';
import 'package:nutrisafe_mitra/features/allergy_monitoring/presentation/student_allergy_monitoring_page.dart';

import 'app/theme/app_theme.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const StudentAllergyMonitoringPage(),
    ),
  );
}
