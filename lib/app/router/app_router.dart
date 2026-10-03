import '../../features/allergy_monitoring/presentation/student_allergy_monitoring_page.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/food_issues/presentation/problematic_food_reports_page.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/session_cubit.dart';
import '../../features/food_report/domain/food_report.dart';
import '../../features/food_report/presentation/food_report_history_page.dart';
import '../../features/food_scan/presentation/food_scan_report_page.dart';
import '../../features/partnership/presentation/partnership_status_page.dart';
import '../../features/partnership/presentation/sppg_registration_page.dart';
import '../../features/partnership/data/sppg_registration_repository.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/schools/presentation/school_list_page.dart';
import '../../features/food_report/presentation/food_report_detail_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/notifications/presentation/notification_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/profile/presentation/edit_profile_page.dart';
import '../../features/profile/presentation/help_page.dart';
import '../../features/profile/presentation/change_password_page.dart';
import 'widgets/main_navigation_shell.dart';

class SessionRefresh extends ChangeNotifier {
  SessionRefresh(SessionCubit session) {
    _subscription = session.stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<SessionState> _subscription;
  Timer? _splashTimer;
  bool _splashFinished = false;
  bool get splashFinished => _splashFinished;

  void startSplash() {
    if (_splashTimer != null || _splashFinished) return;
    _splashTimer = Timer(const Duration(milliseconds: 3000), () {
      _splashFinished = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(
  SessionCubit session,
  SessionRefresh refresh, {
  SppgRegistrationRepository? sppgRegistrationRepository,
}) => GoRouter(
  initialLocation: '/splash',
  refreshListenable: refresh,
  redirect: (context, state) {
    final status = session.state.status;
    final path = state.uri.path;
    final isAuthPage =
        path == '/login' || path == '/register' || path == '/forgot-password';
    if (!refresh.splashFinished ||
        status == SessionStatus.initial ||
        status == SessionStatus.failure) {
      return path == '/splash' ? null : '/splash';
    }
    if (status == SessionStatus.unauthenticated) {
      return isAuthPage ? null : '/login';
    }
    return path == '/splash' || isAuthPage ? '/' : null;
  },
  routes: [
    GoRoute(
      path: '/students/allergies',
      builder: (context, state) => const StudentAllergyMonitoringPage(),
    ),
    GoRoute(
      path: '/food-reports/issues',
      builder: (context, state) => const ProblematicFoodReportsPage(),
    ),
    GoRoute(
      path: '/schools',
      builder: (context, state) => const SchoolListPage(),
    ),
    GoRoute(
      path: '/food-reports/scan',
      builder: (context, state) => const FoodScanReportPage(),
    ),
    GoRoute(
      path: '/food-reports/history',
      builder: (context, state) => const FoodReportHistoryPage(),
    ),
    GoRoute(
      path: '/food-reports/detail',
      redirect: (context, state) =>
          state.extra is FoodReport ? null : '/food-reports/history',
      builder: (context, state) =>
          FoodReportDetailPage(report: state.extra! as FoodReport),
    ),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/partnership/status',
      builder: (context, state) => const PartnershipStatusPage(),
    ),
    GoRoute(
      path: '/partnership/register',
      builder: (context, state) =>
          SppgRegistrationPage(repository: sppgRegistrationRepository),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/profile/help',
      builder: (context, state) => const HelpPage(),
    ),
    GoRoute(
      path: '/profile/change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainNavigationShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Halaman tidak ditemukan.'),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Kembali'),
          ),
        ],
      ),
    ),
  ),
);
