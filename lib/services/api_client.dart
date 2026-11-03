import 'package:dio/dio.dart';
import '../core/config.dart';
import 'stockage_service.dart';

class ApiClient {
  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ));

    // Ajoute automatiquement le jeton à chaque requête
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StockageService.lireToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  static final ApiClient instance = ApiClient._();
  late final Dio dio;

  // Transforme une erreur technique en message lisible
  static String messageErreur(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final erreurs = data['errors'];
        if (erreurs is Map && erreurs.isNotEmpty) {
          final premier = erreurs.values.first;
          if (premier is List && premier.isNotEmpty) {
            return premier.first.toString();
          }
        }
        if (data['message'] != null) return data['message'].toString();
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
      }
    }
    return 'Une erreur est survenue. Réessayez.';
  }
}
