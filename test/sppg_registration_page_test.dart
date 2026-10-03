import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/partnership/data/registration_attachment_picker.dart';
import 'package:nutrisafe_mitra/features/partnership/presentation/sppg_registration_page.dart';

class EmptyPicker implements RegistrationAttachmentPicker {
  @override
  Future<XFile?> pickPdf() async => null;
  @override
  Future<XFile?> pickPhoto({required bool camera}) async => null;
  @override
  Future<List<XFile>> recoverPhotos() async => [];
}

void main() {
  testWidgets(
    'form validates required fields and accepts optional institution',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: SppgRegistrationPage(attachmentPicker: EmptyPicker()),
        ),
      );
      await tester.pumpAndSettle();
      final submit = find.text('Kirim Pendaftaran');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Kolom ini wajib diisi.'), findsNWidgets(6));
      expect(
        find.text('Kapasitas harus berupa angka lebih dari 0.'),
        findsOneWidget,
      );
      final values = [
        'Akbar',
        '',
        '1234567890123456',
        'invalid',
        '+628123456789',
        'SPPG Contoh',
        'Jl. Contoh 1',
        '0',
      ];
      for (var index = 0; index < values.length; index++) {
        final field = find.byType(TextFormField).at(index);
        await tester.ensureVisible(field);
        await tester.enterText(field, values[index]);
      }
      await tester.pumpAndSettle();
      expect(find.text('Format email tidak valid.'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'mitra@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(7), '100');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(
        find.text('Proposal PDF dan foto dapur wajib dilampirkan.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
