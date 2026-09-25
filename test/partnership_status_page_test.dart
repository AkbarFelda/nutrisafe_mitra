import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/partnership/presentation/partnership_status_page.dart';
import 'package:nutrisafe_mitra/features/partnership/presentation/sppg_registration_page.dart';

void main() {
  testWidgets('standalone preview opens registration and returns safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const PartnershipStatusPage()),
    );
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.byType(PartnershipStatusPage), findsOneWidget);
    await tester.tap(find.text('Daftar SPPG Baru'));
    await tester.pumpAndSettle();
    expect(find.byType(SppgRegistrationPage), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.byType(PartnershipStatusPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant({TargetPlatform.linux}));

  testWidgets('partnership content fits narrow screens with enlarged text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const PartnershipStatusPage(),
      ),
    );
    await tester.pumpAndSettle();
  }, variant: TargetPlatformVariant({TargetPlatform.linux}));
}
