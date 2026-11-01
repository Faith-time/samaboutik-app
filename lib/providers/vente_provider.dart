import 'package:flutter/foundation.dart';
import '../models/vente.dart';
import '../services/api_client.dart';
import '../services/vente_service.dart';

class VenteProvider extends ChangeNotifier {
  final _service = VenteService();

  ResumePeriode? resume;
  String periode = '7j';
  bool chargement = false;
  String? erreur;

  Future<void> charger({String? periode}) async {
    if (periode != null) this.periode = periode;
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      resume = await _service.resume(this.periode);
    } catch (e) {
      erreur = ApiClient.messageErreur(e);
    }
    chargement = false;
    notifyListeners();
  }

  /// Crée une vente « en attente » à partir du panier.
  Future<Vente?> creer(List<Map<String, int>> lignes) async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      final v = await _service.creer(lignes);
      chargement = false;
      notifyListeners();
      return v;
    } catch (e) {
      erreur = ApiClient.messageErreur(e);
      chargement = false;
      notifyListeners();
      return null;
    }
  }

  Future<Vente> detail(int id) => _service.detail(id);

  Future<bool> annuler(int id) async {
    try {
      await _service.annuler(id);
      return true;
    } catch (e) {
      erreur = ApiClient.messageErreur(e);
      notifyListeners();
      return false;
    }
  }
}
