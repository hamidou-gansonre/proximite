import 'package:proximite/features/pharmacie_map_guidance/data/data_sources/pharmacie_api_datasource.dart';
import 'package:proximite/features/pharmacie_map_guidance/domain/entities/pharmacie_entitie.dart';
import 'package:proximite/features/pharmacie_map_guidance/domain/entities/repositories/i_pharmacie_repository.dart';

class PharmacieRepositoryImpl implements IPharmacieRepository {
  final PharmacieApiDataSource _apiClient;

  PharmacieRepositoryImpl({required this._apiClient});

  @override
  Future<List<PharmacieEntitie>> getPharmaciesNearBy({
    required double latitude,
    required double longitude,
    required int groupeGarde,
  }) async {
    //Appel des sources de données
    final model = await _apiClient.fetchPharmaciesNearBy(
      latitude: latitude,
      longitude: longitude,
      groupeGarde: groupeGarde,
    );

    // 2. Conversion/Mappage automatique des Modèles en Entités métiers polymorphes
    // Comme PharmacieModel hérite de PharmacieEntitie, la conversion est naturelle et transparente
    return model;
  }
}
