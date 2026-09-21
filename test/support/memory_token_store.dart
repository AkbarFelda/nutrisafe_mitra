import 'package:nutrisafe_mitra/core/storage/token_store.dart';

class MemoryTokenStore implements TokenStore {
  MemoryTokenStore([this.value]);
  String? value;
  bool fail = false;
  void _check() {
    if (fail) throw StateError('Storage unavailable');
  }

  @override
  Future<String?> read() async {
    _check();
    return value;
  }

  @override
  Future<void> write(String token) async {
    _check();
    value = token;
  }

  @override
  Future<void> clear() async {
    _check();
    value = null;
  }
}
