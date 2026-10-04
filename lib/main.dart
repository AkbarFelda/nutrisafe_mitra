import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/dependencies.dart';
import 'features/auth/presentation/session_cubit.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/auth/data/password_repository.dart';
import 'features/partnership/data/sppg_registration_repository.dart';
import 'features/partnership/data/sppg_dashboard_repository.dart';
import 'features/profile/data/profile_repository.dart';

void main() {
  final dependencies = configureDependencies();
  runApp(
    MitraApp(
      session: dependencies<SessionCubit>(),
      authCubit: dependencies<AuthCubit>(),
      passwordRepository: dependencies<PasswordRepository>(),
      profileRepository: dependencies<ProfileRepository>(),
      dashboardRepository: dependencies<SppgDashboardRepository>(),
      sppgRegistrationRepository: dependencies<SppgRegistrationRepository>(),
    ),
  );
}
