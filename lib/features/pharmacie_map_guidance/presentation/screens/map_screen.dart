import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/location_notifier.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/location_state.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/pharmacie_provider.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/pharmacie_state.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/widgets/google_map_view.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/widgets/pharmacie_list_panel.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Déclencher la demande de permission et de position dès l'ouverture de l'application
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).permissionRequest();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pharmacies de garde",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: switch (locationState) {
        LocationInitial() || LocationLoading() => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 16),
              Text("Initialisattion du GPS.."),
            ],
          ),
        ),
        LocationError(:final message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(locationProvider.notifier).permissionRequest(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Réessayer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        LocationSuccess(:final position) => Consumer(
          builder: (context, ref, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final currentState = ref.read(pharmacieProvider);
              if (currentState is PharmacieInitial) {
                print("=== [FLUTTER] Appel unique de l'API ===");
                ref.read(pharmacieProvider.notifier).loadNearByPharmacie();
              }
            });
            final state = ref.watch(pharmacieProvider);

            return Stack(
              children: [
                // 1. La Carte Google Maps viendra ici
                GoogleMapView(),

                // 2. Loader discret
                if (state is PharmacieLoading)
                  const Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                  ),

                //Panneau list view des pharmacies
                const PharmacieListPanel(),
              ],
            );
          },
        ),
        // Si rien des state ne passe
        LocationState() => throw LocationError(
          message: "Quelque chose a mal Tournée",
        ),
      },
    );
  }
}
