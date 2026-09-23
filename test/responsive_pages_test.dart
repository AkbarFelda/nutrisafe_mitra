import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/auth/presentation/login_page.dart';
import 'package:nutrisafe_mitra/features/auth/presentation/register_page.dart';
import 'package:nutrisafe_mitra/features/partnership/presentation/partnership_status_page.dart';
import 'package:nutrisafe_mitra/features/partnership/presentation/sppg_registration_page.dart';

void main() {
  const pages = <String, Widget>{
    'login': LoginPage(),
    'register': RegisterPage(),
    'partnership': PartnershipStatusPage(),
    'SPPG form': SppgRegistrationPage(),
  };
  const scenarios = [
    (name: 'small phone', size: Size(320, 568), scale: 1.0, keyboard: 0.0),
    (name: 'large text', size: Size(320, 568), scale: 2.0, keyboard: 0.0),
    (
      name: 'landscape keyboard',
      size: Size(844, 390),
      scale: 1.0,
      keyboard: 180.0,
    ),
    (name: 'tablet', size: Size(1200, 900), scale: 1.5, keyboard: 0.0),
  ];
  for (final page in pages.entries) {
    for (final scenario in scenarios) {
      testWidgets('${page.key}: ${scenario.name}', (tester) async {
        await tester.binding.setSurfaceSize(scenario.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scenario.scale),
                viewInsets: EdgeInsets.only(bottom: scenario.keyboard),
              ),
              child: child!,
            ),
            home: page.value,
          ),
        );
        await tester.pumpAndSettle();
        final scroll = find.byType(SingleChildScrollView).first;
        await tester.drag(scroll, const Offset(0, -1200));
        await tester.pumpAndSettle();
      }, variant: TargetPlatformVariant({TargetPlatform.linux}));
    }
  }
}
