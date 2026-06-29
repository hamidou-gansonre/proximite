import 'package:proximite/features/pharmacie_map_guidance/domain/entities/pharmacie_entitie.dart';

//I au debut pour specifier que c'est Interface
abstract class IPharmacieRepository {
  /// Récupère la liste des pharmacies converties en entités métiers propre sans calcule
  Future<List<PharmacieEntitie>> getPharmaciesNearBy({
    required double latitude,
    required double longitude,
    required int groupeGarde,
  });
}
