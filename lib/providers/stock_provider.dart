import 'package:flutter/foundation.dart';
import '../models/stock.dart';
import '../services/api_client.dart';
import '../services/stock_service.dart';

class StockProvider extends ChangeNotifier {
  final _service = StockService();

  // ---- État du stock ----
  StockDonnees? donnees;
  bool chargement = false;
  String? erreur;

  // ---- Classement ----
  String periode = 'semaine';
  String tri = 'quantite';
  Classement? classement;
  bool chargementClassement = false;
  String? erreurClassement;

  // ---- Achats ----
  List<Approvisionnement> achats = [];
  bool chargementAchats = false;
  String? erreurAchats;

  // ---- Actions (achat, correction) ----
  String? erreurAction;

  StockProduit? produit(int id) {
    for (final p in donnees?.produits ?? const <StockProduit>[]) {
      if (p.produitId == id) return p;
    }
    return null;
  }

  /// Produits épuisés d'abord, puis ceux qui seront finis le plus tôt.
  List<StockProduit> get alertes {
    final l = (donnees?.produits ?? const <StockProduit>[])
        .where((p) => p.alerte)
        .toList();
    l.sort((a, b) {
      if (a.epuise != b.epuise) return a.epuise ? -1 : 1;
      return (a.joursRestants ?? 9999).compareTo(b.joursRestants ?? 9999);
    });
    return l;
  }

  Future<void> charger() async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      donnees = await _service.charger();
    } catch (e) {
      erreur = ApiClient.messageErreur(e);
    }
    chargement = false;
    notifyListeners();
  }

  Future<void> chargerClassement({String? periode, String? tri}) async {
    if (periode != null) this.periode = periode;
    if (tri != null) this.tri = tri;
    chargementClassement = true;
    erreurClassement = null;
    notifyListeners();
    try {
      classement = await _service.classement(this.periode, this.tri);
    } catch (e) {
      erreurClassement = ApiClient.messageErreur(e);
    }
    chargementClassement = false;
    notifyListeners();
  }

  Future<void> chargerAchats() async {
    chargementAchats = true;
    erreurAchats = null;
    notifyListeners();
    try {
      achats = await _service.achats();
    } catch (e) {
      erreurAchats = ApiClient.messageErreur(e);
    }
    chargementAchats = false;
    notifyListeners();
  }

  Future<bool> enregistrerAchat({
    String? fournisseur,
    required List<Map<String, dynamic>> lignes,
  }) async {
    erreurAction = null;
    try {
      await _service.enregistrerAchat(fournisseur: fournisseur, lignes: lignes);
      await Future.wait([charger(), chargerAchats()]);
      return true;
    } catch (e) {
      erreurAction = ApiClient.messageErreur(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> corriger(int produitId, int stockReel, {String? note}) async {
    erreurAction = null;
    try {
      await _service.corriger(produitId, stockReel, note: note);
      await charger();
      return true;
    } catch (e) {
      erreurAction = ApiClient.messageErreur(e);
      notifyListeners();
      return false;
    }
  }

  /// Crée ou modifie un produit (avec ses réglages de stock). Lance une erreur lisible en cas d'échec.
  Future<int> enregistrerProduit({int? id, required Map<String, dynamic> champs}) =>
      _service.enregistrerProduit(id: id, donnees: champs);
}
