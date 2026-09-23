import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';

import 'package:nutrisafe_mitra/features/partnership/presentation/partnership_status_page.dart';

// import 'app/app.dart';
// import 'app/di/dependencies.dart';
// import 'features/auth/presentation/session_cubit.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   final dependencies = configureDependencies();
//   runApp(MitraApp(session: dependencies<SessionCubit>()));
// }

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(body: const PartnershipStatusPage()),
    ),
  );
}
