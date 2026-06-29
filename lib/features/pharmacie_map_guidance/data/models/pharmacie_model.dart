import 'package:proximite/features/pharmacie_map_guidance/domain/entities/pharmacie_entitie.dart';

class PharmacieModel extends PharmacieEntitie {
  PharmacieModel({
    required super.id,
    required super.name,
    required super.telephone,
    required super.secteur,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.distanceKm,
  });

  // Convertit le JSON du backend Node.js en objet de notre application
  factory PharmacieModel.fromJson(Map<String, dynamic> json) {
    return PharmacieModel(
      id: json['id'] as int,
      name: json['nom'] as String,
      telephone: json['telephone'] as String,
      secteur: json['secteur'] as String,
      description: json['description'] as String? ?? '',
      // Sécurité : conversion explicite en double si le backend renvoie un int
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
    );
  }

  // Convertit l'objet si tu as besoin de l'envoyer dans un body HTTP plus tard
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'telephone': telephone,
      'secteur': secteur,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'distanceKm': distanceKm,
    };
  }
}
