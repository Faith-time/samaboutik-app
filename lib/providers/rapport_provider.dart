import 'package:flutter/foundation.dart';
import '../models/rapport_ia.dart';
import '../services/api_client.dart';
import '../services/rapport_service.dart';

class RapportProvider extends ChangeNotifier {
  final _service = RapportService();

  RapportIa? rapport;
  bool chargement = false;
  String? erreur;

  Future<void> charger() async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      rapport = await _service.obtenir();
    } catch (e) {
      erreur = ApiClient.messageErreur(e);
    }
    chargement = false;
    notifyListeners();
  }
}
