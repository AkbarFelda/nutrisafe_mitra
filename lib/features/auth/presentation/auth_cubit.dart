import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_failure.dart';
import '../data/auth_repository.dart';
import 'session_cubit.dart';

enum AuthActionStatus { initial, loading, success, failure }

class AuthActionState extends Equatable {
  const AuthActionState({this.status = AuthActionStatus.initial, this.message});

  final AuthActionStatus status;
  final String? message;

  @override
  List<Object?> get props => [status, message];
}

class AuthCubit extends Cubit<AuthActionState> {
  AuthCubit(this._repository, this._session) : super(const AuthActionState());

  final AuthRepository _repository;
  final SessionCubit _session;

  Future<void> login({required String email, required String password}) async {
    if (state.status == AuthActionStatus.loading) return;
    emit(const AuthActionState(status: AuthActionStatus.loading));
    try {
      final token = await _repository.login(
        LoginCredentials(email: email.trim(), password: password),
      );
      await _session.acceptAuthenticatedToken(token);
      if (!isClosed) {
        emit(const AuthActionState(status: AuthActionStatus.success));
      }
    } on AppFailure catch (failure) {
      if (!isClosed) {
        emit(
          AuthActionState(
            status: AuthActionStatus.failure,
            message: failure.message,
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    if (state.status == AuthActionStatus.loading) return;
    emit(const AuthActionState(status: AuthActionStatus.loading));
    String? warning;
    try {
      await _repository.logout();
    } on AppFailure catch (failure) {
      warning = failure.message;
    } finally {
      await _session.logout();
    }
    if (!isClosed) {
      emit(AuthActionState(status: AuthActionStatus.success, message: warning));
    }
  }
}
