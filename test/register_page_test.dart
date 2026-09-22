import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/auth/presentation/register_page.dart';

void main() {
  testWidgets('rejects empty registration and filters non-digit phone input', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const RegisterPage()),
    );
    await tester.ensureVisible(find.text('Daftar'));
    await tester.tap(find.text('Daftar'));
    await tester.pump();
    expect(find.text('Nama lengkap wajib diisi.'), findsOneWidget);
    expect(find.text('Email wajib diisi.'), findsOneWidget);
    expect(find.text('Password wajib diisi.'), findsOneWidget);
    expect(find.text('Nomor HP wajib diisi.'), findsOneWidget);
    expect(find.text('Kategori wajib diisi.'), findsOneWidget);

    final phone = find.byType(TextFormField).at(3);
    await tester.ensureVisible(phone);
    await tester.enterText(phone, '0812abc-345 678');
    await tester.pump();
    expect(tester.widget<TextFormField>(phone).controller!.text, '812345678');
    expect(find.text('Nomor HP wajib diisi.'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('+62'), findsOneWidget);
    for (final input in ['+62 812-345-678', '62812345678', '812345678']) {
      await tester.enterText(phone, input);
      await tester.pump();
      expect(tester.widget<TextFormField>(phone).controller!.text, '812345678');
    }
  });
}
