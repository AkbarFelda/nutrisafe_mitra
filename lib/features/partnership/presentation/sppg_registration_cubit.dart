import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_failure.dart';
import '../data/sppg_registration_repository.dart';
import '../data/sppg_registration_request.dart';

enum SppgRegistrationStatus { initial, loading, success, failure }

class SppgRegistrationState extends Equatable {
  const SppgRegistrationState({
    this.status = SppgRegistrationStatus.initial,
    this.message,
  });

  final SppgRegistrationStatus status;
  final String? message;

  @override
  List<Object?> get props => [status, message];
}

class SppgRegistrationCubit extends Cubit<SppgRegistrationState> {
  SppgRegistrationCubit(this._repository)
    : super(const SppgRegistrationState());

  final SppgRegistrationRepository _repository;

  Future<void> submit(SppgRegistrationRequest request) async {
    if (state.status == SppgRegistrationStatus.loading) return;
    emit(const SppgRegistrationState(status: SppgRegistrationStatus.loading));
    try {
      await _repository.register(request);
      if (!isClosed) {
        emit(
          const SppgRegistrationState(
            status: SppgRegistrationStatus.success,
            message: 'Pendaftaran SPPG berhasil dikirim.',
          ),
        );
      }
    } on AppFailure catch (failure) {
      if (!isClosed) {
        emit(
          SppgRegistrationState(
            status: SppgRegistrationStatus.failure,
            message: failure.message,
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          SppgRegistrationState(
            status: SppgRegistrationStatus.failure,
            message: AppFailure.from(error).message,
          ),
        );
      }
    }
  }
}
