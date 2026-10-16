import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/app.dart';
import 'package:nutrisafe_mitra/app/di/dependencies.dart';
import 'package:nutrisafe_mitra/features/auth/presentation/session_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrisafe_mitra/features/partnership/presentation/partnership_status_page.dart';
import 'package:nutrisafe_mitra/features/partnership/presentation/sppg_registration_page.dart';

import 'support/memory_token_store.dart';

import 'package:nutrisafe_mitra/features/food_report/domain/food_report.dart';
import 'package:nutrisafe_mitra/features/food_report/presentation/food_report_detail_page.dart';
import 'package:nutrisafe_mitra/features/food_report/presentation/food_report_history_page.dart';
import 'package:nutrisafe_mitra/features/home/presentation/home_page.dart';

void main() {
  testWidgets('detail route requires and displays the selected report', (
    tester,
  ) async {
    final di = configureDependencies(
      tokenStore: MemoryTokenStore('test-token'),
    );
    await tester.pumpWidget(MitraApp(session: di<SessionCubit>()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(HomePage)));
    for (final extra in [null, 'invalid']) {
      router.go('/food-reports/detail', extra: extra);
      await tester.pumpAndSettle();
      expect(find.byType(FoodReportHistoryPage), findsOneWidget);
      expect(find.byType(FoodReportDetailPage), findsNothing);
    }
    final report = FoodReport(
      date: DateTime(2026, 3, 23),
      school: 'Sekolah Rute',
      address: 'Alamat Rute',
      portions: 42,
    );
    router.push('/food-reports/detail', extra: report);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FoodReportDetailPage>(find.byType(FoodReportDetailPage))
          .report,
      same(report),
    );
    expect(find.text('Sekolah Rute'), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.byType(FoodReportHistoryPage), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await di.reset();
  });
  testWidgets('restores logged-out state and protects shell', (tester) async {
    final di = configureDependencies(tokenStore: MemoryTokenStore());
    await tester.pumpWidget(MitraApp(session: di<SessionCubit>()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Nutrisafe'), findsOneWidget);
    expect(find.text('Masuk Akun'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Masuk Akun'), findsOneWidget);
    await tester.ensureVisible(find.text('Daftar Jadi Mitra'));
    await tester.tap(find.text('Daftar Jadi Mitra'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Jadi Mitra SPPG'), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk Akun'), findsOneWidget);
    final context = tester.element(find.text('Masuk Akun'));
    GoRouter.of(context).go('/');
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsNothing);
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
    expect(find.byType(HomePage), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-menu-/partnership/status')));
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
    expect(find.byType(HomePage), findsOneWidget);
    final router = GoRouter.of(tester.element(find.byType(HomePage)));
    router.go('/unknown-test-route');
    await tester.pumpAndSettle();
    expect(find.text('Halaman tidak ditemukan.'), findsOneWidget);
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    await di<SessionCubit>().logout();
    await tester.pumpAndSettle();
    expect(find.text('Masuk Akun'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await di.reset();
  }, variant: TargetPlatformVariant({TargetPlatform.linux}));
}
