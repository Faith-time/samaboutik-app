import 'package:flutter/foundation.dart';
import '../models/produit.dart';
import '../services/api_client.dart';
import '../services/produit_service.dart';

class ProduitProvider extends ChangeNotifier {
  final _service = ProduitService();

  List<Produit> produits = [];
  bool chargement = false;
  String? erreur;

  List<Produit> get actifs => produits.where((p) => p.actif).toList();

  Future<void> charger() async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      produits = await _service.lister();
    } catch (e) {
      erreur = ApiClient.messageErreur(e);
    }
    chargement = false;
    notifyListeners();
  }

  /// Envoie la photo d'un produit puis met la liste à jour. Lance une erreur en cas d'échec.
  Future<void> televerserImage(int id, String chemin) async {
    final p = await _service.televerserImage(id, chemin);
    produits = produits.map((x) => x.id == p.id ? p : x).toList();
    notifyListeners();
  }

  Future<void> supprimerImage(int id) async {
    final p = await _service.supprimerImage(id);
    produits = produits.map((x) => x.id == p.id ? p : x).toList();
    notifyListeners();
  }

  /// Crée un produit (existant == null) ou modifie un produit existant.
  Future<bool> enregistrer({
    Produit? existant,
    required String nom,
    required int prix,
    int? cout,
    bool actif = true,
  }) async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      if (existant == null) {
        final p = await _service.creer(nom: nom, prix: prix, cout: cout);
        produits = [p, ...produits];
      } else {
        final p = await _service.modifier(existant.id,
            nom: nom, prix: prix, cout: cout, actif: actif);
        produits = produits.map((x) => x.id == p.id ? p : x).toList();
      }
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
