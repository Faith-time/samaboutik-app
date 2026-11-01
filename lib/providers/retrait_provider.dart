import 'package:flutter/foundation.dart';
import '../models/retrait.dart';
import '../services/api_client.dart';
import '../services/retrait_service.dart';

class RetraitProvider extends ChangeNotifier {
  final _service = RetraitService();

  ResumeRetraits? resume;
  bool chargement = false;
  String? erreur;

  Future<void> charger() async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      resume = await _service.lister();
    } catch (e) {
      erreur = ApiClient.messageErreur(e);
    }
    chargement = false;
    notifyListeners();
  }

  Future<bool> retirer(int montantFcfa, String operateur) async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      await _service.creer(montantFcfa: montantFcfa, operateur: operateur);
      resume = await _service.lister();
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
