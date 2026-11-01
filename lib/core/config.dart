class Config {
  // Émulateur Android : 10.0.2.2 = le PC. Vrai téléphone : voir la commande flutter run.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
}
