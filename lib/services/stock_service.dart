import '../core/formatters.dart';
import '../models/stock.dart';
import 'api_client.dart';

Map<String, dynamic> _objet(dynamic d) {
  if (d is Map && d['data'] is Map) {
    return Map<String, dynamic>.from(d['data'] as Map);
  }
  return Map<String, dynamic>.from(d as Map);
}

class StockService {
  final _dio = ApiClient.instance.dio;

  Future<StockDonnees> charger() async {
    final r = await _dio.get('/stock');
    return StockDonnees.fromJson(_objet(r.data));
  }

  /// periode : jour | semaine | mois | annee    tri : quantite | ca | benefice
  Future<Classement> classement(String periode, String tri) async {
    final r = await _dio
        .get('/classement', queryParameters: {'periode': periode, 'tri': tri});
    return Classement.fromJson(_objet(r.data));
  }

  Future<List<Approvisionnement>> achats() async {
    final r = await _dio.get('/approvisionnements');
    final brut = (r.data is Map && r.data['data'] is List) ? r.data['data'] : r.data;
    return versListe(brut).map(Approvisionnement.fromJson).toList();
  }

  /// lignes : [{'produit_id', 'nb_lots', 'unites_par_lot', 'prix_lot_fcfa'}]
  Future<void> enregistrerAchat({
    String? fournisseur,
    required List<Map<String, dynamic>> lignes,
  }) async {
    await _dio.post('/approvisionnements', data: {
      if (fournisseur != null && fournisseur.trim().isNotEmpty)
        'fournisseur': fournisseur.trim(),
      'lignes': lignes,
    });
  }

  Future<void> corriger(int produitId, int stockReel, {String? note}) async {
    await _dio.post('/produits/$produitId/stock/correction', data: {
      'stock_reel': stockReel,
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  /// Crée (id == null) ou modifie un produit, avec ses réglages de stock.
  Future<void> enregistrerProduit({int? id, required Map<String, dynamic> donnees}) async {
    if (id == null) {
      await _dio.post('/produits', data: donnees);
    } else {
      await _dio.put('/produits/$id', data: donnees);
    }
  }
}
