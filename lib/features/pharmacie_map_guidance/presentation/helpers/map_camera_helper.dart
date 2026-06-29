import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/pharmacie_state.dart';

class MapCameraHelper {
  static void ajustDynamicCadrage({
    required GoogleMapController? controller,
    required LatLng userPosition,
    required PharmacieState pharmacieState,
  }) {
    if (controller == null) return;
    List<LatLng> points = [userPosition];

    // Si on a des pharmacies, on les ajoute à la liste des points à afficher
    if (pharmacieState is PharmacieSuccess) {
      for (final p in pharmacieState.pharmacies) {
        points.add(LatLng(p.latitude, p.longitude));
      }
    }

    if (points.length == 1) {
      //s'il ya un seul point , alors c'est Uniquement l'utilisateur -> zoom standard fixe
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userPosition, zoom: 14.5),
        ),
      );
    } else {
      // Plusieurs points USER+Pharmacies -> calcul de la zone de couverture (Bounds)
      double? minLat, maxLat, minLng, maxLng;

      for (final point in points) {
        if (minLat == null || point.latitude < minLat) {
          minLat = point.latitude;
        }
        if (maxLat == null || point.latitude > maxLat) {
          maxLat = point.latitude;
        }
        if (minLng == null || point.longitude < minLng) {
          minLng = point.longitude;
        }
        if (maxLng == null || point.longitude > maxLng) {
          maxLng = point.longitude;
        }
      }

      //on fait un calcule estimatif du Sud au Nord => min to max
      final bounds = LatLngBounds(
        southwest: LatLng(minLat!, minLng!),
        northeast: LatLng(maxLat!, maxLng!),
      );

      // On applique le cadrage avec un décalage de sécurité (padding)
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70.0));
    }
  }
}
