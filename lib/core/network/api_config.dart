class ApiConfig {
  const ApiConfig({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.nutrisafe.id',
    ),
  });
  final String baseUrl;
  bool get isConfigured {
    final uri = Uri.tryParse(baseUrl);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment;
  }
}
