import 'package:flutter/foundation.dart';
import '../models/tableau_bord.dart';
import '../services/api_client.dart';
import '../services/tableau_bord_service.dart';

class TableauBordProvider extends ChangeNotifier {
  final _service = TableauBordService();

  TableauBord? donnees;
  bool chargement = false;
  String? erreur;

  Future<void> charger() async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      donnees = await _service.obtenir();
    } catch (e) {
      erreur = ApiClient.messageErreur(e);
    }
    chargement = false;
    notifyListeners();
  }
}
