import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/features/partnership/data/registration_attachment_picker.dart';
import 'package:nutrisafe_mitra/features/partnership/presentation/widgets/registration_documents.dart';

class FakePicker implements RegistrationAttachmentPicker {
  XFile? result;
  Object? error;
  bool? cameraRequested;
  List<XFile> recovered = [];
  Completer<XFile?>? pending;

  @override
  Future<XFile?> pickPdf() async {
    if (error != null) throw error!;
    return pending == null ? result : await pending!.future;
  }

  @override
  Future<XFile?> pickPhoto({required bool camera}) async {
    cameraRequested = camera;
    return pickPdf();
  }

  @override
  Future<List<XFile>> recoverPhotos() async => recovered;
}

void main() {
  Future<void> mount(
    WidgetTester tester,
    FakePicker picker,
    ValueChanged<List<RegistrationAttachment>> onChanged,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistrationDocuments(picker: picker, onChanged: onChanged),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  XFile pdf(String name) => XFile.fromData(
    Uint8List.fromList('%PDF-1.7\nexample'.codeUnits),
    name: name,
    path: name,
  );

  testWidgets(
    'photo sources only appear after tapping Foto Dapur and can be cancelled',
    (tester) async {
      final picker = FakePicker();
      await mount(tester, picker, (_) {});
      expect(find.text('Ambil Foto'), findsNothing);
      expect(find.text('Pilih dari File'), findsNothing);
      await tester.tap(find.text('Foto Dapur'));
      await tester.pumpAndSettle();
      expect(find.text('Ambil Foto'), findsOneWidget);
      expect(find.text('Pilih dari File'), findsOneWidget);
      expect(picker.cameraRequested, isNull);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Ambil Foto'), findsNothing);
      expect(picker.cameraRequested, isNull);
    },
  );

  testWidgets(
    'PDF selection, cancellation, and removal preserve attachment state',
    (tester) async {
      final picker = FakePicker()..result = pdf('dokumen.pdf');
      List<RegistrationAttachment> files = [];
      await mount(tester, picker, (value) => files = value);
      await tester.tap(find.text('Upload Proposal (PDF)'));
      await tester.pumpAndSettle();
      expect(files.single.name, 'dokumen.pdf');
      picker.result = null;
      await tester.tap(find.text('Upload Proposal (PDF)'));
      await tester.pumpAndSettle();
      expect(files, hasLength(1));
      await tester.tap(find.byTooltip('Hapus dokumen.pdf'));
      await tester.pumpAndSettle();
      expect(files, isEmpty);
    },
  );

  testWidgets('invalid PDF, oversized file and denied permission show errors', (
    tester,
  ) async {
    final picker = FakePicker()
      ..result = XFile.fromData(
        Uint8List.fromList([1, 2, 3]),
        name: 'fake.pdf',
        path: 'fake.pdf',
      );
    await mount(tester, picker, (_) {});
    await tester.tap(find.text('Upload Proposal (PDF)'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih dokumen PDF yang valid.'), findsOneWidget);
    picker.result = XFile.fromData(
      Uint8List(10 * 1024 * 1024 + 1),
      name: 'besar.pdf',
      path: 'besar.pdf',
    );
    await tester.tap(find.text('Upload Proposal (PDF)'));
    await tester.pumpAndSettle();
    expect(find.text('Ukuran file maksimal 10 MB.'), findsOneWidget);
    picker.error = PlatformException(code: 'camera_access_denied');
    await tester.tap(find.text('Foto Dapur'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ambil Foto'));
    await tester.pumpAndSettle();
    expect(picker.cameraRequested, isTrue);
    expect(
      find.textContaining('Izin kamera atau foto ditolak'),
      findsOneWidget,
    );
  });

  testWidgets(
    'gallery and camera add photos; late result after disposal is safe',
    (tester) async {
      final picker = FakePicker()
        ..result = XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          name: 'foto.jpg',
          path: 'foto.jpg',
        );
      List<RegistrationAttachment> files = [];
      await mount(tester, picker, (value) => files = value);
      await tester.tap(find.text('Foto Dapur'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih dari File'));
      await tester.pumpAndSettle();
      expect(picker.cameraRequested, isFalse);
      expect(files.single.isPdf, isFalse);
      await tester.tap(find.text('Foto Dapur'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ambil Foto'));
      await tester.pumpAndSettle();
      expect(picker.cameraRequested, isTrue);
      expect(files, hasLength(2));
      picker.pending = Completer<XFile?>();
      await tester.tap(find.text('Upload Proposal (PDF)'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      picker.pending!.complete(pdf('late.pdf'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('recovered photos are restored and attachment count is bounded', (
    tester,
  ) async {
    final picker = FakePicker()
      ..recovered = [
        XFile.fromData(
          Uint8List.fromList([1]),
          name: 'recovered.jpg',
          path: 'recovered.jpg',
        ),
      ];
    List<RegistrationAttachment> files = [];
    await mount(tester, picker, (value) => files = value);
    expect(files.single.name, 'recovered.jpg');
    for (var i = 0; i < 4; i++) {
      picker.result = pdf('$i.pdf');
      await tester.tap(find.text('Upload Proposal (PDF)'));
      await tester.pumpAndSettle();
    }
    expect(files, hasLength(5));
    final button = find.ancestor(
      of: find.text('Upload Proposal (PDF)'),
      matching: find.byType(OutlinedButton),
    );
    expect(tester.widget<OutlinedButton>(button).onPressed, isNull);
  });
}
