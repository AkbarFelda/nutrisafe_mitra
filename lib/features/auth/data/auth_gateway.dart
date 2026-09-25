

abstract interface class AuthGateway<Credentials> {
  Future<String> authenticate(Credentials credentials);
}
