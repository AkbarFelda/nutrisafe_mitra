import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/session_cubit.dart';
import '../../features/splash/presentation/splash_screen.dart';

class SessionRefresh extends ChangeNotifier {
  SessionRefresh(SessionCubit session) {
    _subscription = session.stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<SessionState> _subscription;
  Timer? _splashTimer;
  bool _splashFinished = false;
  bool get splashFinished => _splashFinished;

  /// Presentation-only delay, started after the application's first frame.
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
    if (!refresh.splashFinished ||
        status == SessionStatus.initial ||
        status == SessionStatus.failure) {
      return path == '/splash' ? null : '/splash';
    }
    if (status == SessionStatus.unauthenticated) {
      return path == '/login' ? null : '/login';
    }
    return path == '/splash' || path == '/login' ? '/' : null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
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
          builder: (context, state) =>
              const Center(child: Text('Beranda Mitra/SPPG')),
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
