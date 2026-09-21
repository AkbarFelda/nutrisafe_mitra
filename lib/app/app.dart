import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/session_cubit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class MitraApp extends StatefulWidget {
  const MitraApp({super.key, required this.session});
  final SessionCubit session;
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
    _router = createRouter(widget.session, _refresh);
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
