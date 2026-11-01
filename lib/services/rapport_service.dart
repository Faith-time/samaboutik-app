import '../core/formatters.dart';
import '../models/rapport_ia.dart';
import 'api_client.dart';
import '../core/routes.dart';

class RapportService {
  final _dio = ApiClient.instance.dio;

  Future<RapportIa> obtenir() async {
    final r = await _dio.get('/rapport-ia');
    return RapportIa.fromJson(Map<String, dynamic>.from(corps(r.data)));
  }
}
