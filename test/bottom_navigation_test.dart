import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/app.dart';
import 'package:nutrisafe_mitra/app/di/dependencies.dart';
import 'package:nutrisafe_mitra/features/auth/presentation/session_cubit.dart';

import 'support/memory_token_store.dart';

void main() {
  testWidgets('switches between the three primary destinations', (
    tester,
  ) async {
    final dependencies = configureDependencies(
      tokenStore: MemoryTokenStore('test-token'),
    );

    await tester.pumpWidget(
      MitraApp(session: dependencies<SessionCubit>()),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Menu Mitra'), findsOneWidget);
    expect(find.byKey(const Key('bottom-nav-beranda')), findsOneWidget);

    await tester.tap(find.byKey(const Key('bottom-nav-notifikasi')));
    await tester.pumpAndSettle();
    expect(find.text('Notifikasi'), findsWidgets);
    expect(find.byKey(const Key('notification-list')), findsOneWidget);

    await tester.tap(find.byKey(const Key('bottom-nav-profile')));
    await tester.pumpAndSettle();
    expect(find.text('Profil'), findsOneWidget);
    expect(find.byKey(const Key('profile-scroll-view')), findsOneWidget);

    await tester.tap(find.byKey(const Key('bottom-nav-beranda')));
    await tester.pumpAndSettle();
    expect(find.text('Menu Mitra'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await dependencies.reset();
  });
}
