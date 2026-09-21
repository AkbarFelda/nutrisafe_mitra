/// Backend integration boundary, intentionally unregistered until a real API
/// contract is supplied. Credentials is the future contract-specific input;
/// the returned string is a normalized access token, not a response schema.
abstract interface class AuthGateway<Credentials> {
  Future<String> authenticate(Credentials credentials);
}
