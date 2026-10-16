import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrisafe_mitra/core/network/api_config.dart';
import 'package:nutrisafe_mitra/core/network/dio_factory.dart';
import 'package:nutrisafe_mitra/features/auth/data/password_repository.dart';
import 'package:nutrisafe_mitra/features/auth/data/session_repository.dart';
import 'package:nutrisafe_mitra/features/auth/presentation/session_cubit.dart';
import 'package:nutrisafe_mitra/features/partnership/data/sppg_dashboard_repository.dart';
import 'package:nutrisafe_mitra/features/profile/data/profile_repository.dart';
import 'package:nutrisafe_mitra/features/profile/data/sppg_profile.dart';
import 'package:nutrisafe_mitra/features/profile/presentation/change_password_page.dart';
import 'package:nutrisafe_mitra/features/schools/presentation/school_list_page.dart';

import 'support/memory_token_store.dart';

class _ApiAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  bool schoolAssigned = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.path == '/sppg/assign-schools') schoolAssigned = true;
    final body = switch (options.path) {
      '/sppg/profile' => '{"data":{"name":"Dapur Sehat","email":"dapur@sppg.id","phone":"0812","lokasi":"Bandung","institution_name":"Yayasan"}}',
      '/sppg/status' => '{"data":{"status":"Aktif","sppg_name":"Dapur Sehat","address":"Bandung","production_capacity":100,"school_count":2}}',
      '/sppg/available-schools' when schoolAssigned => '{"data":{"schools":[],"total_school":0,"total_students":0},"status":"success"}',
      '/sppg/available-schools' => '{"data":{"schools":[{"id":7,"name":"SD Contoh","address":"Bandung","Grade":"SD/MI","teacher_count":8,"student_count":100,"allergy_types":["Kacang"]}],"total_school":1,"total_students":100},"status":"success"}',
      '/sppg/schools' when schoolAssigned => '{"data":{"schools":[{"id":7,"name":"SD Contoh","address":"Bandung","Grade":"SD/MI","teacher_count":8,"student_count":100,"allergy_types":["Kacang"]}]},"status":"success"}',
      '/sppg/schools' => '{"data":{"schools":[]},"status":"success"}',
      '/sppg/allergy-dashboard' => '{"data":{"schools":[{"name":"SD Contoh","students":100,"allergies":{"peanut":2,"egg":1,"milk":1}}]}}',
      _ => '{"status":"success"}',
    };
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _DeliveryHistoryAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '''{"data":[{"date":"2026-10-16","schools":[{"report_id":1,"school_id":4,"school_name":"SDN 1 Tembokrejo","address":"Jalan Melati No. 30, Tembokrejo","total_portions":1,"status":"pending"}]}],"status":"success"}''',
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late _ApiAdapter adapter;

  setUp(() {
    dio = createDio(
      config: const ApiConfig(baseUrl: 'https://api.nutrisafe.id'),
      token: () => 'secret-token',
      onUnauthorized: (_) async {},
    );
    adapter = _ApiAdapter();
    dio.httpClientAdapter = adapter;
  });
  tearDown(() => dio.close());

  test('profile detail and edit use bearer token and expected JSON', () async {
    final repository = ProfileRepository(dio);
    final profile = await repository.getProfile();
    expect(profile.name, 'Dapur Sehat');
    await repository.updateProfile(
      const SppgProfile(
        name: 'SPPG Dapur Sehat Bandung',
        email: 'dapursehat@sppg.id',
        phone: '081298765432',
        location: 'Jl. Merdeka No. 12, Bandung',
        institutionName: 'Yayasan Gizi Nusantara',
      ),
    );
    expect(
      adapter.requests.first.headers['Authorization'],
      'Bearer secret-token',
    );
    expect(adapter.requests.last.method, 'PUT');
    expect(adapter.requests.last.data['lokasi'], 'Jl. Merdeka No. 12, Bandung');
  });

  test('password endpoints use correct authentication and payloads', () async {
    final repository = PasswordRepository(dio);
    await repository.requestResetCode('user@example.com');
    await repository.resetPassword(
      email: 'user@example.com',
      code: '042234',
      newPassword: 'PasswordBaru123',
    );
    await repository.changePassword(
      oldPassword: 'PasswordBaru123',
      newPassword: 'passwordBaru1234',
    );
    expect(adapter.requests[0].path, '/forgot-password/request');
    expect(adapter.requests[0].headers['Authorization'], isNull);
    expect(adapter.requests[1].path, '/forgot-password/verify');
    expect(adapter.requests[1].data['code'], '042234');
    expect(adapter.requests[2].path, '/change-password');
    expect(adapter.requests[2].headers['Authorization'], 'Bearer secret-token');
    expect(adapter.requests[2].data['old_password'], 'PasswordBaru123');
  });

  test('status, schools and scan endpoints use bearer token', () async {
    final repository = SppgDashboardRepository(dio);
    final status = await repository.getStatus();
    final schools = await repository.getAvailableSchools();
    await repository.scanFood(imageBytes: Uint8List.fromList([1, 2, 3]));
    await repository.assignSchools([7, 8]);
    final allergies = await repository.getAllergyDashboard();
    expect(status.name, 'Dapur Sehat');
    expect(schools.single.name, 'SD Contoh');
    expect(schools.single.id, 7);
    expect(schools.single.students, 100);
    expect(schools.single.teachers, 8);
    expect(schools.single.allergyTypes, ['Kacang']);
    expect(adapter.requests.map((request) => request.path), [
      '/sppg/status',
      '/sppg/available-schools',
      '/sppg/scan',
      '/sppg/assign-schools',
      '/sppg/allergy-dashboard',
    ]);
    expect(
      adapter.requests.every(
        (request) => request.headers['Authorization'] == 'Bearer secret-token',
      ),
      isTrue,
    );
    final scanData = adapter.requests[2].data as FormData;
    expect(scanData.fields.single.key, 'total_portions');
    expect(scanData.fields.single.value, '1');
    expect(scanData.files.single.key, 'image');
    expect(adapter.requests[3].data['school_ids'], [7, 8]);
    expect(allergies.schools.single.allergicStudents, 4);
  });

  test('live SPPG status and scan response shapes are parsed correctly', () {
    final status = SppgStatus.fromJson({
      'is_partner': true,
      'school_count': 2,
      'sppg_list': [
        {
          'name': 'Felagine',
          'status': 'active',
          'address': 'Alamat dapur',
          'capacity': 500,
        },
      ],
    });
    final scan = ScanResult.fromResponse({
      'status': 'success',
      'data': {
        'bahan_terdeteksi': [
          {'name': 'Nasi', 'is_allergen': false},
          {'name': 'Kacang', 'is_allergen': true},
        ],
        'kalori_per_porsi': '12.0',
        'menu_detail': {
          'kalori': 120,
          'protein': 60,
          'karbohidrat': 100,
          'lemak': 40,
        },
        'peringatan_alergi': ['Kacang'],
        'status_gizi': 'Kurang',
        'total_porsi': 10,
      },
    });

    expect(status.name, 'Felagine');
    expect(status.capacity, 500);
    expect(status.schoolCount, 2);
    expect(scan.ingredients.map((item) => item.name), ['Nasi', 'Kacang']);
    expect(scan.ingredients.last.isAllergen, isTrue);
    expect(scan.allergyWarnings, ['Kacang']);
    expect(scan.nutrientPerPortion('kalori'), 12);
    expect(scan.nutrientPerPortion('protein'), 6);
    expect(scan.nutrientTotal('protein'), 60);
    expect(scan.nutritionStatus, 'Kurang');
  });

  test('scan response can be decoded when Dio receives a JSON string', () {
    final scan = ScanResult.fromResponse('''
      {"status":"success","data":{"bahan_terdeteksi":[
        {"name":"Nasi","is_allergen":false},
        {"name":"Pisang","is_allergen":false},
        {"name":"Tempe","is_allergen":false}
      ],"gemini_failed":false}}
    ''');

    expect(scan.ingredients.map((item) => item.name), [
      'Nasi',
      'Pisang',
      'Tempe',
    ]);
    expect(scan.geminiFailed, isFalse);
  });

  test('delivery history unwraps grouped list response from API', () async {
    final customDio = createDio(
      config: const ApiConfig(baseUrl: 'https://api.nutrisafe.id'),
      token: () => 'secret-token',
      onUnauthorized: (_) async {},
    );
    customDio.httpClientAdapter = _DeliveryHistoryAdapter();
    addTearDown(customDio.close);

    final reports = await SppgDashboardRepository(
      customDio,
    ).getDeliveryReports(month: 10, year: 2026);

    expect(reports, hasLength(1));
    expect(reports.single.id, 1);
    expect(reports.single.school, 'SDN 1 Tembokrejo');
    expect(reports.single.address, 'Jalan Melati No. 30, Tembokrejo');
    expect(reports.single.portions, 1);
  });

  testWidgets('successful password change logs out only after OK', (
    tester,
  ) async {
    final store = MemoryTokenStore();
    final session = SessionCubit(SessionRepository(store));
    addTearDown(session.close);
    await session.acceptAuthenticatedToken('secret-token');
    final repository = PasswordRepository(dio);
    final router = GoRouter(
      initialLocation: '/change',
      routes: [
        GoRoute(
          path: '/change',
          builder: (_, _) =>
              ChangePasswordPage(repository: repository, session: session),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Halaman Login')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'PasswordBaru123');
    await tester.enterText(fields.at(1), 'passwordBaru1234');
    await tester.enterText(fields.at(2), 'passwordBaru1234');
    final submit = find.byKey(const Key('change-password-button'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('Kata Sandi Berhasil Diubah'), findsOneWidget);
    expect(store.value, 'secret-token');
    await tester.tap(find.byKey(const Key('change-password-success-ok')));
    await tester.pumpAndSettle();
    expect(store.value, isNull);
    expect(session.state.status, SessionStatus.unauthenticated);
    expect(find.text('Halaman Login'), findsOneWidget);
  });

  testWidgets('available school card clearly shows selected state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SchoolListPage(repository: SppgDashboardRepository(dio)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Alergi Kacang'), findsOneWidget);
    final checkbox = find.byKey(const Key('school-checkbox-7'));
    await tester.tap(checkbox);
    await tester.pump();
    expect(find.text('Terpilih'), findsOneWidget);
    final button = find.byKey(const Key('assign-schools-button'));
    await tester.ensureVisible(button);
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Sekolah berhasil dihubungkan.'), findsOneWidget);
    expect(find.text('Tidak ada sekolah yang tersedia'), findsOneWidget);
    await tester.tap(find.text('Terhubung'));
    await tester.pumpAndSettle();
    expect(find.text('SD Contoh').hitTestable(), findsOneWidget);
  });
}
