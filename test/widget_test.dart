import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/app.dart';
import 'package:nutrisafe_mitra/app/di/dependencies.dart';
import 'package:nutrisafe_mitra/features/auth/presentation/session_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrisafe_mitra/features/partnership/presentation/partnership_status_page.dart';
import 'package:nutrisafe_mitra/features/partnership/presentation/sppg_registration_page.dart';

import 'support/memory_token_store.dart';

void main() {
  testWidgets('restores logged-out state and protects shell', (tester) async {
    final di = configureDependencies(tokenStore: MemoryTokenStore());
    await tester.pumpWidget(MitraApp(session: di<SessionCubit>()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Nutrisafe'), findsOneWidget);
    expect(find.text('Masuk Akun'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Masuk Akun'), findsOneWidget);
    await tester.ensureVisible(find.text('Daftar'));
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Akun'), findsOneWidget);
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk Akun'), findsOneWidget);
    final context = tester.element(find.text('Masuk Akun'));
    GoRouter.of(context).go('/');
    await tester.pumpAndSettle();
    expect(find.text('Beranda Mitra/SPPG'), findsNothing);
    GoRouter.of(context).go('/partnership/status');
    await tester.pumpAndSettle();
    expect(find.byType(PartnershipStatusPage), findsNothing);
    GoRouter.of(context).go('/partnership/register');
    await tester.pumpAndSettle();
    expect(find.byType(SppgRegistrationPage), findsNothing);
    expect(find.text('Masuk Akun'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await di.reset();
  }, variant: TargetPlatformVariant({TargetPlatform.linux}));
  testWidgets('restores session, handles not found, and logs out', (
    tester,
  ) async {
    final di = configureDependencies(
      tokenStore: MemoryTokenStore('test-token'),
    );
    await tester.pumpWidget(MitraApp(session: di<SessionCubit>()));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('Beranda Mitra/SPPG'), findsOneWidget);
    await tester.tap(find.text('Status Kemitraan'));
    await tester.pumpAndSettle();
    expect(find.byType(PartnershipStatusPage), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    await tester.tap(find.text('Daftar SPPG Baru'));
    await tester.pumpAndSettle();
    expect(find.byType(SppgRegistrationPage), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.byType(PartnershipStatusPage), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Beranda Mitra/SPPG'), findsOneWidget);
    final router = GoRouter.of(tester.element(find.text('Beranda Mitra/SPPG')));
    router.go('/unknown-test-route');
    await tester.pumpAndSettle();
    expect(find.text('Halaman tidak ditemukan.'), findsOneWidget);
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk Akun'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await di.reset();
  }, variant: TargetPlatformVariant({TargetPlatform.linux}));
}
