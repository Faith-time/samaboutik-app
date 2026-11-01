import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/stockage_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  Utilisateur? utilisateur;
  bool chargement = false;
  bool initialise = false; // false tant qu'on n'a pas vérifié le jeton au démarrage
  bool bienvenueVue = false;
  String? erreur;

  bool get estConnecte => utilisateur != null;

  // Au démarrage : écrans de bienvenue déjà vus ? jeton existant ?
  Future<void> demarrer() async {
    bienvenueVue = await StockageService.bienvenueVue();
    final token = await StockageService.lireToken();
    if (token != null) {
      try {
        utilisateur = await _service.moi();
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          await StockageService.effacerToken();
        }
      }
    }
    initialise = true;
    notifyListeners();
  }

  Future<void> marquerBienvenueVue() async {
    await StockageService.marquerBienvenueVue();
    bienvenueVue = true;
    notifyListeners();
  }

  Future<bool> connexion(String telephone, String motDePasse) => _executer(
        () async {
          utilisateur = await _service.connexion(
            telephone: telephone,
            motDePasse: motDePasse,
          );
        },
      );

  Future<bool> inscription({
    required String nom,
    required String telephone,
    required String motDePasse,
    required String nomBoutique,
  }) =>
      _executer(() async {
        utilisateur = await _service.inscription(
          nom: nom,
          telephone: telephone,
          motDePasse: motDePasse,
          nomBoutique: nomBoutique,
        );
      });

  Future<void> deconnexion() async {
    await _service.deconnexion();
    utilisateur = null;
    erreur = null;
    notifyListeners();
  }

  Future<bool> _executer(Future<void> Function() action) async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      await action();
      chargement = false;
      notifyListeners();
      return true;
    } catch (e) {
      erreur = ApiClient.messageErreur(e);
      chargement = false;
      notifyListeners();
      return false;
    }
  }
}
