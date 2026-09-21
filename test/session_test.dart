import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisafe_mitra/features/auth/data/session_repository.dart';
import 'package:nutrisafe_mitra/features/auth/presentation/session_cubit.dart';

import 'support/memory_token_store.dart';

void main() {
  late MemoryTokenStore store;
  late SessionRepository repository;
  late SessionCubit session;
  setUp(() {
    store = MemoryTokenStore();
    repository = SessionRepository(store);
    session = SessionCubit(repository);
  });
  tearDown(() => session.close());
  test('missing and blank tokens do not restore a session', () async {
    await session.restore();
    expect(session.state.status, SessionStatus.unauthenticated);
    store.value = '  ';
    await session.restore();
    expect(session.state.status, SessionStatus.unauthenticated);
  });
  test('persist, restore, logout and clear in-memory token', () async {
    await session.acceptAuthenticatedToken('test-token');
    expect(store.value, 'test-token');
    await session.restore();
    expect(session.state.status, SessionStatus.authenticated);
    await session.logout();
    expect(store.value, isNull);
    expect(repository.token, isNull);
    expect(session.state.status, SessionStatus.unauthenticated);
  });
  test('stale unauthorized response cannot delete newer session', () async {
    await session.acceptAuthenticatedToken('new-token');
    await session.invalidate('old-token');
    expect(session.state.status, SessionStatus.authenticated);
    await session.invalidate('new-token');
    expect(session.state.status, SessionStatus.unauthenticated);
  });
  test('logout queued during restoration wins', () async {
    store.value = 'stored-token';
    await Future.wait([session.restore(), session.logout()]);
    expect(session.state.status, SessionStatus.unauthenticated);
    expect(store.value, isNull);
  });
  test('storage failure fails closed and supports retry', () async {
    await session.acceptAuthenticatedToken('test-token');
    store.fail = true;
    await session.logout();
    expect(session.state.status, SessionStatus.failure);
    expect(repository.token, isNull);
    final failure = session.state.failure;
    await session.invalidate('test-token');
    expect(session.state.failure, same(failure));
    store.fail = false;
    await session.logout();
    expect(session.state.status, SessionStatus.unauthenticated);
    expect(store.value, isNull);
  });
}
