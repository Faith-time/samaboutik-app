import '../core/formatters.dart';
import '../models/vente.dart';
import 'api_client.dart';
import '../core/routes.dart';

class VenteService {
  final _dio = ApiClient.instance.dio;

  /// [lignes] : [{'produit_id': 3, 'quantite': 2}, ...]
  Future<Vente> creer(List<Map<String, int>> lignes) async {
    final r = await _dio.post('/ventes', data: {'lignes': lignes});
    return Vente.fromJson(Map<String, dynamic>.from(corps(r.data)));
  }

  /// periode : '7j', '30j' ou '3m'
  Future<ResumePeriode> resume(String periode) async {
    final r = await _dio.get('/ventes', queryParameters: {'periode': periode});
    return ResumePeriode.fromJson(Map<String, dynamic>.from(corps(r.data)));
  }

  Future<Vente> detail(int id) async {
    final r = await _dio.get('/ventes/$id');
    return Vente.fromJson(Map<String, dynamic>.from(corps(r.data)));
  }

  Future<Vente> annuler(int id) async {
    final r = await _dio.post('/ventes/$id/annuler');
    return Vente.fromJson(Map<String, dynamic>.from(corps(r.data)));
  }
}
