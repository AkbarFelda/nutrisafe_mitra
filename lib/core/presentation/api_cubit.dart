import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/app_failure.dart';

enum ApiStatus { initial, loading, success, failure }

class ApiState<T> extends Equatable {
  const ApiState({this.status = ApiStatus.initial, this.data, this.message});

  final ApiStatus status;
  final T? data;
  final String? message;

  @override
  List<Object?> get props => [status, data, message];
}

class ApiCubit<T> extends Cubit<ApiState<T>> {
  ApiCubit() : super(const ApiState());

  Future<bool> run(
    Future<T> Function() request, {
    String? successMessage,
  }) async {
    if (state.status == ApiStatus.loading) return false;
    emit(ApiState(status: ApiStatus.loading, data: state.data));
    try {
      final data = await request();
      if (!isClosed) {
        emit(
          ApiState(
            status: ApiStatus.success,
            data: data,
            message: successMessage,
          ),
        );
      }
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(
          ApiState(
            status: ApiStatus.failure,
            data: state.data,
            message: AppFailure.from(error).message,
          ),
        );
      }
      return false;
    }
  }
}
