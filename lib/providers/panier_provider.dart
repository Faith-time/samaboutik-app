import 'package:flutter/foundation.dart';
import '../models/produit.dart';

class PanierProvider extends ChangeNotifier {
  final Map<int, Produit> _produits = {};
  final Map<int, int> _quantites = {};

  int quantite(int produitId) => _quantites[produitId] ?? 0;
  bool get vide => _quantites.isEmpty;

  int get nombreArticles => _quantites.values.fold<int>(0, (a, b) => a + b);

  int get total => _quantites.entries.fold<int>(
      0, (s, e) => s + e.value * (_produits[e.key]?.prixFcfa ?? 0));

  /// Format attendu par l'API : [{'produit_id': 3, 'quantite': 2}]
  List<Map<String, int>> get lignesApi => _quantites.entries
      .map((e) => {'produit_id': e.key, 'quantite': e.value})
      .toList();

  void ajouter(Produit p) {
    _produits[p.id] = p;
    _quantites[p.id] = quantite(p.id) + 1;
    notifyListeners();
  }

  void retirer(Produit p) {
    final q = quantite(p.id);
    if (q <= 1) {
      _quantites.remove(p.id);
      _produits.remove(p.id);
    } else {
      _quantites[p.id] = q - 1;
    }
    notifyListeners();
  }

  void vider() {
    _quantites.clear();
    _produits.clear();
    notifyListeners();
  }
}
