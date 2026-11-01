import 'package:flutter/foundation.dart';
import '../models/paiement.dart';
import '../services/api_client.dart';
import '../services/paiement_service.dart';

class PaiementProvider extends ChangeNotifier {
  final _service = PaiementService();

  Paiement? paiement;
  bool chargement = false;
  String? erreur;

  /// Lance un paiement : espèces, lightning, wave, orange_money ou free_money.
  Future<Paiement?> payer(int venteId, String methode) async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      paiement = await _service.creer(venteId, methode);
      chargement = false;
      notifyListeners();
      return paiement;
    } catch (e) {
      erreur = ApiClient.messageErreur(e);
      chargement = false;
      notifyListeners();
      return null;
    }
  }

  /// Demande au serveur le statut actuel (le serveur est la seule source fiable).
  Future<void> rafraichir() async {
    final actuel = paiement;
    if (actuel == null) return;
    try {
      final nouveau = await _service.statut(actuel.id);
      paiement = nouveau.completeAvec(actuel);
      notifyListeners();
    } catch (_) {
      // Pas de réseau : on réessaiera au prochain passage.
    }
  }
}
