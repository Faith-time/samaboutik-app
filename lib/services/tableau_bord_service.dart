import '../core/formatters.dart';
import '../models/tableau_bord.dart';
import 'api_client.dart';

class TableauBordService {
  final _dio = ApiClient.instance.dio;

  Future<TableauBord> obtenir() async {
    final r = await _dio.get('/tableau-de-bord');
    return TableauBord.fromJson(Map<String, dynamic>.from(corps(r.data)));
  }
}
