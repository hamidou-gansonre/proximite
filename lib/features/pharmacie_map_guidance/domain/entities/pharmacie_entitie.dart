class PharmacieEntitie {
  final int id;
  final String name;
  final String telephone;
  final String secteur ;
  final String description;
  final double latitude;
  final double longitude;
  final double distanceKm;

  const PharmacieEntitie({
    required this.id,
    required this.name,
    required this.telephone,
    required this.secteur,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.distanceKm, 
  });

  
}