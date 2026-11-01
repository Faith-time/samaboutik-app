import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/routes.dart';

class StockageService {
  static const _storage = FlutterSecureStorage();
  static const _cleToken = 'token';
  static const _cleBienvenue = 'bienvenue_vue';
  static const _clePremierPaiement = 'premier_paiement_bitcoin_vu';

  // Le jeton de connexion est gardé dans un stockage sécurisé
  static Future<String?> lireToken() => _storage.read(key: _cleToken);
  static Future<void> sauverToken(String token) =>
      _storage.write(key: _cleToken, value: token);
  static Future<void> effacerToken() => _storage.delete(key: _cleToken);

  // Pour afficher les écrans de bienvenue une seule fois
  static Future<bool> bienvenueVue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cleBienvenue) ?? false;
  }

  static Future<void> marquerBienvenueVue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cleBienvenue, true);
  }

  // Message d'explication du premier paiement Bitcoin (affiché une seule fois)
  static Future<bool> premierPaiementVu() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_clePremierPaiement) ?? false;
  }

  static Future<void> marquerPremierPaiementVu() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clePremierPaiement, true);
  }
}
