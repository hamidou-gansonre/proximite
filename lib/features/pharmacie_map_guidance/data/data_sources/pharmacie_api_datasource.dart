import 'package:dio/dio.dart';
import 'package:proximite/core/constants/api_constants.dart';
import 'package:proximite/features/pharmacie_map_guidance/data/models/pharmacie_model.dart';

class PharmacieApiDataSource {
  final Dio _dio;

  // On injecte Dio pour faciliter les futurs tests unitaires
  PharmacieApiDataSource({required this._dio});

  /// Interroge le backend Node.js pour obtenir les pharmacies de garde les plus proches
  Future<List<PharmacieModel>> fetchPharmaciesNearBy({
    required double latitude,
    required double longitude,
    required int groupeGarde,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.pharmaciesProchesEndpoint}',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'groupe': groupeGarde,
        },
      );

      // Validation de la structure des données response
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> listData = response.data['data'] as List<dynamic>;
        return listData
            .map(
              (json) => PharmacieModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        //We can implement more throwing here
        throw Exception(
          response.data['error'] ?? "Erreur inconnue du serveur.",
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['error'] ?? "Impossible de contacter le serveur.";
      throw Exception("Erreur du Réseau : $errorMessage");
    } catch (e) {
      throw Exception("Erreur de parsing des données : $e");
    }
  }
}
