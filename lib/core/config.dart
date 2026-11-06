class Config {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://samaboutik.alwaysdata.net/api',
  );
}