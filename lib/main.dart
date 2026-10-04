import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/dependencies.dart';
import 'features/auth/presentation/session_cubit.dart';
import 'features/partnership/data/sppg_registration_repository.dart';

void main() {
  final dependencies = configureDependencies();
  runApp(
    MitraApp(
      session: dependencies<SessionCubit>(),
      sppgRegistrationRepository: dependencies<SppgRegistrationRepository>(),
    ),
  );
}
