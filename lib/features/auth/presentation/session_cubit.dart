import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_failure.dart';
import '../data/session_repository.dart';

enum SessionStatus { initial, authenticated, unauthenticated, failure }

class SessionState extends Equatable {
  const SessionState(this.status, {this.failure});
  final SessionStatus status;
  final AppFailure? failure;
  @override
  List<Object?> get props => [status, failure];
}

class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._repository)
    : super(const SessionState(SessionStatus.initial));
  final SessionRepository _repository;
  Future<void> _pending = Future<void>.value();

  Future<void> _enqueue(Future<SessionStatus?> Function() action) {
    _pending = _pending.then((_) async {
      if (isClosed) return;
      try {
        final status = await action();
        if (!isClosed && status != null) emit(SessionState(status));
      } catch (error) {
        if (!isClosed) {
          emit(
            SessionState(
              SessionStatus.failure,
              failure: AppFailure(FailureKind.storage, cause: error),
            ),
          );
        }
      }
    });
    return _pending;
  }

  Future<void> restore() => _enqueue(
    () async => await _repository.restore()
        ? SessionStatus.authenticated
        : SessionStatus.unauthenticated,
  );

  Future<void> acceptAuthenticatedToken(String token) => _enqueue(() async {
    await _repository.save(token);
    return SessionStatus.authenticated;
  });
  Future<void> logout() => _enqueue(() async {
    await _repository.clear();
    return SessionStatus.unauthenticated;
  });
  Future<void> invalidate(String rejectedToken) => _enqueue(() async {

    if (_repository.token != rejectedToken) return null;
    await _repository.clear();
    return SessionStatus.unauthenticated;
  });
}
