import '../core/formatters.dart';
import '../core/routes.dart';
import '../models/paiement.dart';
import 'api_client.dart';

class PaiementService {
  final _dio = ApiClient.instance.dio;

  /// methode : especes | lightning | wave | orange_money | free_money
  Future<Paiement> creer(int venteId, String methode) async {
    final r = await _dio.post(
      ApiRoutes.paiementVente(venteId, methode),
      // Espèces et Lightning n'ont pas besoin de corps ; le mobile money précise l'opérateur
      data: (methode == 'especes' || methode == 'lightning')
          ? null
          : {'methode': methode},
    );
    return Paiement.fromJson(Map<String, dynamic>.from(corps(r.data)));
  }

  Future<Paiement> statut(int paiementId) async {
    final r = await _dio.get(ApiRoutes.paiement(paiementId));
    return Paiement.fromJson(Map<String, dynamic>.from(corps(r.data)));
  }
}