import '../core/formatters.dart';
import '../models/produit.dart';
import 'api_client.dart';

class ProduitService {
  final _dio = ApiClient.instance.dio;

  Future<List<Produit>> lister() async {
    final r = await _dio.get('/produits');
    return versListe(corps(r.data)).map(Produit.fromJson).toList();
  }

  Future<Produit> creer(
      {required String nom, required int prix, int? cout}) async {
    final r = await _dio.post('/produits',
        data: {'nom': nom, 'prix_fcfa': prix, 'cout_fcfa': cout});
    return Produit.fromJson(Map<String, dynamic>.from(corps(r.data)));
  }

  Future<Produit> modifier(int id,
      {required String nom,
      required int prix,
      int? cout,
      required bool actif}) async {
    final r = await _dio.put('/produits/$id', data: {
      'nom': nom,
      'prix_fcfa': prix,
      'cout_fcfa': cout,
      'actif': actif,
    });
    return Produit.fromJson(Map<String, dynamic>.from(corps(r.data)));
  }
}
