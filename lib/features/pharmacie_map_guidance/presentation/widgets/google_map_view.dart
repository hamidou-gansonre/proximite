import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/helpers/map_camera_helper.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/location_notifier.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/location_state.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/pharmacie_provider.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/pharmacie_state.dart';

class GoogleMapView extends ConsumerStatefulWidget {
  const GoogleMapView({super.key});

  @override
  ConsumerState<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends ConsumerState<GoogleMapView> {
  GoogleMapController? _mapController;
  bool _aAnimeVersUser = false;

  @override
  Widget build(BuildContext context) {
    // 1. Écouter la position de l'utilisateur (Pour centrer la carte au départ)
    final locationState = ref.watch(locationProvider);
    // 2. Écouter l'état des pharmacies (Pour dessiner les marqueurs)
    final pharmacieState = ref.watch(pharmacieProvider);

    // Coordonnées par défaut (Centre de Ouagadougou) au cas où le GPS tarde
    LatLng googleMapsCenter = const LatLng(12.3714, -1.5197);
    final Set<Marker> marqueurs = {};

    // Si la localisation est un succès, on cible la vraie position de l'utilisateur
    if (locationState is LocationSuccess) {
      googleMapsCenter = LatLng(
        locationState.position.latitude,
        locationState.position.longitude,
      );

      // Ajout du marqueur de l'utilisateur
      marqueurs.add(
        Marker(
          markerId: const MarkerId('user_position'),
          position: googleMapsCenter,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: "Votre Position"),
        ),
      );
    }

    /*  if (!_aAnimeVersUser) {
        WidgetsBinding.instance.addPersistentFrameCallback((_) {
          _recenterUserCamera(googleMapsCenter);
          setState(() {
            _aAnimeVersUser = true;
          });
        });
      }
    }
    **/

    // Si les pharmacies sont chargées avec succès,
    // on les ajoute sur la carte

    if (pharmacieState is PharmacieSuccess) {
      for (final pharmacie in pharmacieState.pharmacies) {
        marqueurs.add(
          Marker(
            markerId: MarkerId("'pharmacie_${pharmacie.id}'"),
            position: LatLng(pharmacie.latitude, pharmacie.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(
              title: pharmacie.name,
              snippet: "${pharmacie.secteur} - Tél: ${pharmacie.telephone}",
            ),
          ),
        );
      }
    }

    //Gestion des animations du camera via le helper

    if (locationState is LocationSuccess && !_aAnimeVersUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mapController != null) {
          MapCameraHelper.ajustDynamicCadrage(
            controller: _mapController,
            userPosition: googleMapsCenter,
            pharmacieState: pharmacieState,
          );
          _aAnimeVersUser = true;
        }
      });
    }

    ref.listen(pharmacieProvider, (previous, next) {
      if (locationState is LocationSuccess && next is PharmacieSuccess) {
        MapCameraHelper.ajustDynamicCadrage(
          controller: _mapController,
          userPosition: googleMapsCenter,
          pharmacieState: next,
        );
      }
    });

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: googleMapsCenter,
            zoom:
                14.5, // Niveau de zoom idéal pour voir les rues de son secteur
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            if (locationState is LocationSuccess) {
              MapCameraHelper.ajustDynamicCadrage(
                controller: _mapController,
                userPosition: googleMapsCenter,
                pharmacieState: pharmacieState,
              );
              _aAnimeVersUser = true;
            }
          },
          markers: marqueurs,
          myLocationButtonEnabled:
              false, //TODOS : // On créera notre propre bouton stylisé plus tard
          myLocationEnabled:
              false, // Géré manuellement via notre marqueur Azure
          zoomControlsEnabled:
              false, // Épure l'interface pour un rendu plus moderne (SaaS style)
        ),
        // --- BOUTON DE RECENTRAGE FLOTTANT STYLE SAAS ---
        if (locationState is LocationSuccess)
          Positioned(
            right: 16,
            bottom: 110,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade700,

              onPressed: () => MapCameraHelper.ajustDynamicCadrage(
                controller: _mapController,
                userPosition: googleMapsCenter,
                pharmacieState: ref.read(pharmacieProvider),
              ),
              child: const Icon(Icons.my_location),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
