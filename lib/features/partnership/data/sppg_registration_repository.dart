import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/error/app_failure.dart';
import 'sppg_registration_request.dart';

class SppgRegistrationRepository {
  const SppgRegistrationRepository(this._dio);

  final Dio _dio;

  Future<void> register(SppgRegistrationRequest request) async {
    try {
      await _dio.post<Object?>(
        '/register/sppg',
        data: FormData.fromMap({
          'registrant_name': request.registrantName,
          'institution_name': request.institutionName,
          'nik_npwp': request.nikNpwp,
          'email': request.email,
          'phone': request.phone,
          'sppg_name': request.sppgName,
          'sppg_address': request.sppgAddress,
          'production_capacity': request.productionCapacity,
          'proposal': MultipartFile.fromBytes(
            request.proposalBytes,
            filename: request.proposalName,
            contentType: MediaType('application', 'pdf'),
          ),
          'kitchen_photo': MultipartFile.fromBytes(
            request.kitchenPhotoBytes,
            filename: request.kitchenPhotoName,
            contentType: _imageMediaType(request.kitchenPhotoName),
          ),
        }),
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          extra: const {'requiresAuth': false},
        ),
      );
    } on DioException catch (error) {
      final message = _responseMessage(error.response?.data);
      if (message != null) {
        throw AppFailure(
          FailureKind.unexpected,
          cause: error,
          messageOverride: message,
        );
      }
      throw AppFailure.from(error);
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  MediaType _imageMediaType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      'heic' => MediaType('image', 'heic'),
      'heif' => MediaType('image', 'heif'),
      _ => MediaType('image', 'jpeg'),
    };
  }

  String? _responseMessage(Object? body) {
    if (body is! Map) return null;
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    final errors = body['errors'];
    if (errors is Map) {
      final messages = errors.values
          .expand<String>((value) {
            if (value is List) return value.whereType<String>();
            if (value is String) return [value];
            return const [];
          })
          .where((value) => value.trim().isNotEmpty)
          .toList();
      if (messages.isNotEmpty) return messages.join('\n');
    }
    return null;
  }
}
