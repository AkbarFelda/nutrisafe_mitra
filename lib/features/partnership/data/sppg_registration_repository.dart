import 'package:dio/dio.dart';

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
          ),
          'kitchen_photo': MultipartFile.fromBytes(
            request.kitchenPhotoBytes,
            filename: request.kitchenPhotoName,
          ),
        }),
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          extra: const {'requiresAuth': false},
        ),
      );
    } catch (error) {
      throw AppFailure.from(error);
    }
  }
}
