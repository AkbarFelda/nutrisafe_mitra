import 'package:dio/dio.dart';

enum FailureKind {
  network,
  timeout,
  unauthorized,
  invalidCredentials,
  server,
  unexpected,
  configuration,
  storage,
}

class AppFailure implements Exception {
  const AppFailure(this.kind, {this.cause, this.messageOverride});
  final FailureKind kind;
  final Object? cause;
  final String? messageOverride;
  String get message =>
      messageOverride ??
      switch (kind) {
        FailureKind.network => 'Periksa koneksi internet Anda.',
        FailureKind.timeout => 'Permintaan terlalu lama. Coba lagi.',
        FailureKind.unauthorized => 'Sesi berakhir. Silakan masuk kembali.',
        FailureKind.invalidCredentials => 'Email atau kata sandi tidak sesuai.',
        FailureKind.server => 'Layanan sedang bermasalah. Coba lagi nanti.',
        FailureKind.configuration => 'Layanan belum tersedia.',
        FailureKind.storage => 'Sesi tidak dapat disimpan atau dibaca.',
        FailureKind.unexpected => 'Terjadi kesalahan. Silakan coba lagi.',
      };
  static AppFailure from(Object error) {
    if (error is AppFailure) return error;
    if (error is DioException) {
      if (error.error is AppFailure) return error.error! as AppFailure;
      final status = error.response?.statusCode;
      return AppFailure(switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => FailureKind.timeout,
        DioExceptionType.connectionError => FailureKind.network,
        _ when status == 401 => FailureKind.unauthorized,
        _ when status != null && status >= 500 => FailureKind.server,
        _ => FailureKind.unexpected,
      }, cause: error);
    }
    return AppFailure(FailureKind.unexpected, cause: error);
  }
}
