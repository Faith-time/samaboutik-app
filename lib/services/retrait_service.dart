import '../core/formatters.dart';
import '../models/retrait.dart';
import 'api_client.dart';
import '../core/routes.dart';

class RetraitService {
  final _dio = ApiClient.instance.dio;

  Future<ResumeRetraits> lister() async {
    final r = await _dio.get('/retraits');
    return ResumeRetraits.fromJson(Map<String, dynamic>.from(corps(r.data)));
  }

  Future<void> creer(
      {required int montantFcfa, required String operateur}) async {
    await _dio.post('/retraits',
        data: {'montant_fcfa': montantFcfa, 'operateur': operateur});
  }
}
