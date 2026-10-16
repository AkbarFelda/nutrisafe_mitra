import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/auth/presentation/login_page.dart';

void main() {
  testWidgets('validates empty login fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LoginPage()),
    );
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    expect(find.text('Email wajib diisi.'), findsOneWidget);
    expect(find.text('Password wajib diisi.'), findsOneWidget);
  });

  testWidgets('only accepts SPPG email domain', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LoginPage()),
    );
    await tester.enterText(
      find.byType(TextFormField).first,
      'sekolah@example.sch.id',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    expect(find.text('Gunakan email dengan domain @sppg.id.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'dapur.subang@sppg.id',
    );
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    expect(find.text('Gunakan email dengan domain @sppg.id.'), findsNothing);
  });

  testWidgets('password visibility toggles without losing entered text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LoginPage()),
    );
    final password = find.byType(TextFormField).last;
    await tester.enterText(password, 'example-password');
    EditableText field() => tester.widget<EditableText>(
      find.descendant(of: password, matching: find.byType(EditableText)),
    );

    expect(field().obscureText, isTrue);
    await tester.tap(find.byTooltip('Tampilkan password'));
    await tester.pump();
    expect(field().obscureText, isFalse);
    expect(field().controller.text, 'example-password');
    await tester.tap(find.byTooltip('Sembunyikan password'));
    await tester.pump();
    expect(field().obscureText, isTrue);
    expect(field().controller.text, 'example-password');
  });
}
