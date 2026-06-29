import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/location_state.dart';

class LocationNotifier extends StateNotifier<LocationState>{
  LocationNotifier() : super(const LocationInitial());

/// Vérifie les permissions et récupère la position actuelle de l'utilisateur
  Future<void> permissionRequest() async {
    state = const LocationLoading();

    try {

      bool isServiceEnabled;
      LocationPermission permission;
      Position position;

      // 1. Vérifier si le service de localisation est activé sur le téléphone
      isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if(!isServiceEnabled) {
        state =  LocationError(message: "Le service de localisation (GPS) est désactivé.");
        return;
      }

      // 2. Vérifier le statut des permissions
      permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.denied) {
        //Si la permission n'est pas encore autoriser ,
        // il faut demander encore une fois
        permission = await Geolocator.requestPermission();
        if(permission == LocationPermission.denied) {
          //L'utilisateur a refuser. On passe
          state = LocationError(message: "Les permissions de localisation sont refusées.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state =  LocationError(
          message: "Les permissions de localisation sont définitivement refusées. Veuillez les activer dans les paramètres.",
        );
        return;
      }


      //Maintenant tout est ok ,
      // on a la permisssion de localisation


      // 3. Récupérer la position avec une précision équilibrée
      position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Met à jour si l'utilisateur bouge de 5 mètres
        ),
      );

      //Tout est Ok ,
      //On renvoie un State Success
      state = LocationSuccess(position);

    } catch (e) {
      state = LocationError(message: "Erreur lors de la récupération du GPS : $e" ) ;
    }
  }


  /// Permet d'écouter la position de l'utilisateur en temps réel (pour le guidage)
  /// 
  Stream<Position> get fluxPosition => Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2,// Précision accrue pour le calcul des virages (2 mètres)
    ),
  );
}

// Le provider global accessible partout dans l'application
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});