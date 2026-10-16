import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_config.dart';
import '../../core/network/dio_factory.dart';
import '../../core/network/mock_api_interceptor.dart';
import '../../core/storage/token_store.dart';
import '../../features/auth/data/session_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/password_repository.dart';
import '../../features/auth/presentation/auth_cubit.dart';
import '../../features/auth/presentation/session_cubit.dart';
import '../../features/partnership/data/sppg_registration_repository.dart';
import '../../features/partnership/data/sppg_dashboard_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/notifications/data/notification_repository.dart';

GetIt configureDependencies({
  ApiConfig config = const ApiConfig(),
  TokenStore? tokenStore,
  bool useMockApi = const bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  ),
}) {
  final di = GetIt.asNewInstance();
  di.registerSingleton<ApiConfig>(config);
  di.registerSingleton<TokenStore>(
    tokenStore ?? SecureTokenStore(const FlutterSecureStorage()),
  );
  di.registerLazySingleton(() => SessionRepository(di<TokenStore>()));
  di.registerLazySingleton(
    () => SessionCubit(di<SessionRepository>()),
    dispose: (cubit) => cubit.close(),
  );
  di.registerLazySingleton<Dio>(() {
    final dio = createDio(
      config: di<ApiConfig>(),
      token: () => di<SessionRepository>().token,
      onUnauthorized: di<SessionCubit>().invalidate,
    );
    if (useMockApi) {
      dio.interceptors.insert(0, MockApiInterceptor());
    }
    return dio;
  }, dispose: (dio) => dio.close(force: true));
  di.registerLazySingleton(() => AuthRepository(di<Dio>()));
  di.registerLazySingleton(() => PasswordRepository(di<Dio>()));
  di.registerLazySingleton(() => ProfileRepository(di<Dio>()));
  di.registerLazySingleton(() => NotificationRepository(di<Dio>()));
  di.registerLazySingleton(() => SppgDashboardRepository(di<Dio>()));
  di.registerLazySingleton(
    () => AuthCubit(di<AuthRepository>(), di<SessionCubit>()),
    dispose: (cubit) => cubit.close(),
  );
  di.registerLazySingleton(() => SppgRegistrationRepository(di<Dio>()));
  return di;
}
