import '../models/utilisateur.dart';
import 'api_client.dart';
import 'stockage_service.dart';

class AuthService {
  final _dio = ApiClient.instance.dio;

  Future<Utilisateur> inscription({
    required String nom,
    required String telephone,
    required String motDePasse,
    required String nomBoutique,
  }) async {
    final r = await _dio.post('/inscription', data: {
      'nom': nom,
      'telephone': telephone,
      'mot_de_passe': motDePasse,
      'nom_boutique': nomBoutique,
    });
    await StockageService.sauverToken(r.data['token']);
    return Utilisateur.fromJson(r.data['utilisateur']);
  }

  Future<Utilisateur> connexion({
    required String telephone,
    required String motDePasse,
  }) async {
    final r = await _dio.post('/connexion', data: {
      'telephone': telephone,
      'mot_de_passe': motDePasse,
    });
    await StockageService.sauverToken(r.data['token']);
    return Utilisateur.fromJson(r.data['utilisateur']);
  }

  Future<Utilisateur> moi() async {
    final r = await _dio.get('/moi');
    return Utilisateur.fromJson(r.data);
  }

  Future<void> deconnexion() async {
    try {
      await _dio.post('/deconnexion');
    } catch (_) {
      // Même sans réseau, on supprime le jeton du téléphone
    }
    await StockageService.effacerToken();
  }
}
