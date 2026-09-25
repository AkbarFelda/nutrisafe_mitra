import 'package:flutter/material.dart';
import 'package:nutrisafe_mitra/features/schools/presentation/school_list_page.dart';

import 'app/theme/app_theme.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SchoolListPage(),
    ),
  );
}
