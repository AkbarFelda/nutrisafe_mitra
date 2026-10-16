import '../../../core/storage/token_store.dart';

class SessionRepository {
  SessionRepository(this._store);
  final TokenStore _store;
  String? _token;
  String? get token => _token;
  Future<bool> restore() async {
    final stored = await _store.read();
    _token = stored != null && stored.trim().isNotEmpty ? stored : null;
    return _token != null;
  }

  Future<void> save(String token) async {
    if (token.trim().isEmpty) throw ArgumentError('Token must not be empty');
    await _store.write(token);
    _token = token;
  }

  Future<void> clear() async {
    _token = null;
    await _store.clear();
  }
}
