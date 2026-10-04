import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/features/partnership/data/sppg_registration_repository.dart';
import 'package:nutrisafe_mitra/features/partnership/data/sppg_registration_request.dart';

class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      '{"message":"ok"}',
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('sends SPPG registration as multipart form data', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.nutrisafe.id'));
    addTearDown(() => dio.close());
    final adapter = _RecordingAdapter();
    dio.httpClientAdapter = adapter;
    final repository = SppgRegistrationRepository(dio);

    await repository.register(
      SppgRegistrationRequest(
        registrantName: 'Fadhil',
        institutionName: 'NutriSafe',
        nikNpwp: '1256897542246865',
        email: 'mzssdaru@gmail.com',
        phone: '08122334444',
        sppgName: 'Fadhil',
        sppgAddress: 'Jalanin aja',
        productionCapacity: 7,
        proposalName: 'proposal.pdf',
        proposalBytes: Uint8List.fromList('%PDF-test'.codeUnits),
        kitchenPhotoName: 'dapur.jpg',
        kitchenPhotoBytes: Uint8List.fromList([1, 2, 3]),
      ),
    );

    expect(adapter.request!.path, '/register/sppg');
    expect(adapter.request!.extra['requiresAuth'], isFalse);
    final data = adapter.request!.data as FormData;
    expect(
      Map.fromEntries(data.fields),
      containsPair('registrant_name', 'Fadhil'),
    );
    expect(
      Map.fromEntries(data.fields),
      containsPair('production_capacity', '7'),
    );
    expect(data.files.map((entry) => entry.key), ['proposal', 'kitchen_photo']);
    expect(data.files.first.value.filename, 'proposal.pdf');
    expect(data.files.last.value.filename, 'dapur.jpg');
  });
}
