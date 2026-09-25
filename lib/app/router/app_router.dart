import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/session_cubit.dart';
import '../../features/food_report/domain/food_report.dart';
import '../../features/food_report/presentation/food_report_history_page.dart';
import '../../features/partnership/presentation/partnership_status_page.dart';
import '../../features/partnership/presentation/sppg_registration_page.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/schools/presentation/school_list_page.dart';
import '../../features/food_report/presentation/food_report_detail_page.dart';

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

GoRouter createRouter(SessionCubit session, SessionRefresh refresh) => GoRouter(
  initialLocation: '/splash',
  refreshListenable: refresh,
  redirect: (context, state) {
    final status = session.state.status;
    final path = state.uri.path;
    final isAuthPage = path == '/login' || path == '/register';
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
      path: '/schools',
      builder: (context, state) => const SchoolListPage(),
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
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/partnership/status',
      builder: (context, state) => const PartnershipStatusPage(),
    ),
    GoRoute(
      path: '/partnership/register',
      builder: (context, state) => const SppgRegistrationPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => Scaffold(
        appBar: AppBar(
          title: const Text('NutriSafe Mitra'),
          actions: [
            TextButton(
              onPressed: () => context.read<SessionCubit>().logout(),
              child: const Text('Keluar'),
            ),
          ],
        ),
        body: child,
      ),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Beranda Mitra/SPPG'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/schools'),
                  child: const Text('Daftar Sekolah'),
                ),
                TextButton(
                  onPressed: () => context.push('/partnership/status'),
                  child: const Text('Status Kemitraan'),
                ),
                TextButton(
                  onPressed: () => context.push('/food-reports/history'),
                  child: const Text('Riwayat Laporan Makanan'),
                ),
              ],
            ),
          ),
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
