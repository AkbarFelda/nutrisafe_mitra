import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/auth/presentation/forgot_password_page.dart';

void main() {
  testWidgets('completes forgot password steps', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ForgotPasswordPage()),
    );

    await tester.enterText(
      find.byKey(const Key('forgot-email-field')),
      'mitra@nutrisafe.id',
    );
    await tester.tap(find.text('Kirim Kode'));
    await tester.pumpAndSettle();

    expect(find.text('Verifikasi Kode'), findsOneWidget);
    for (var index = 0; index < 6; index++) {
      await tester.enterText(
        find.byKey(Key('otp-field-$index')),
        '${index + 1}',
      );
    }
    await tester.tap(find.text('Verifikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Buat Kata Sandi Baru'), findsOneWidget);
    final passwordFields = find.byType(TextFormField);
    await tester.enterText(passwordFields.at(0), 'PasswordBaru1!');
    await tester.enterText(passwordFields.at(1), 'PasswordBaru1!');
    await tester.tap(find.text('Simpan Kata Sandi'));
    await tester.pumpAndSettle();

    expect(find.text('Kata Sandi Berhasil Diubah'), findsOneWidget);
  });
}
