import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/session_cubit.dart';
import '../features/auth/presentation/auth_cubit.dart';
import '../features/auth/data/password_repository.dart';
import '../features/partnership/data/sppg_registration_repository.dart';
import '../features/partnership/data/sppg_dashboard_repository.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/notifications/data/notification_repository.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class MitraApp extends StatefulWidget {
  const MitraApp({
    super.key,
    required this.session,
    this.authCubit,
    this.passwordRepository,
    this.profileRepository,
    this.dashboardRepository,
    this.sppgRegistrationRepository,
    this.notificationRepository,
  });
  final SessionCubit session;
  final AuthCubit? authCubit;
  final PasswordRepository? passwordRepository;
  final ProfileRepository? profileRepository;
  final SppgDashboardRepository? dashboardRepository;
  final SppgRegistrationRepository? sppgRegistrationRepository;
  final NotificationRepository? notificationRepository;
  @override
  State<MitraApp> createState() => _MitraAppState();
}

class _MitraAppState extends State<MitraApp> {
  late final SessionRefresh _refresh;
  late final GoRouter _router;
  @override
  void initState() {
    super.initState();
    _refresh = SessionRefresh(widget.session);
    _router = createRouter(
      widget.session,
      _refresh,
      authCubit: widget.authCubit,
      passwordRepository: widget.passwordRepository,
      profileRepository: widget.profileRepository,
      dashboardRepository: widget.dashboardRepository,
      sppgRegistrationRepository: widget.sppgRegistrationRepository,
      notificationRepository: widget.notificationRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh.startSplash();
    });
    widget.session.restore();
  }

  @override
  void dispose() {
    _router.dispose();
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: widget.session,
    child: MaterialApp.router(
      title: 'NutriSafe Mitra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    ),
  );
}
