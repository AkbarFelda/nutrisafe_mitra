import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/app/theme/app_theme.dart';
import 'package:nutrisafe_mitra/features/auth/data/session_repository.dart';
import 'package:nutrisafe_mitra/features/auth/presentation/session_cubit.dart';
import 'package:nutrisafe_mitra/features/splash/presentation/splash_screen.dart';

import 'support/memory_token_store.dart';

void main() {
  testWidgets('bundled logo decodes and renders on splash', (tester) async {
    final session = SessionCubit(SessionRepository(MemoryTokenStore()));
    await tester.pumpWidget(
      BlocProvider.value(
        value: session,
        child: MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    await tester.runAsync(
      () => precacheImage(image.image, tester.element(find.byType(Image))),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Nutrisafe'), findsOneWidget);
    final rendered = tester.widget<RawImage>(find.byType(RawImage));
    expect(rendered.image, isNotNull);
    await tester.pumpWidget(const SizedBox());
    await session.close();
  });
}
