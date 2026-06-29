import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:proximite/features/pharmacie_map_guidance/domain/entities/repositories/i_pharmacie_repository.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/location_notifier.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/location_state.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/pharmacie_di_provider.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/pharmacie_state.dart';

class PharmacieNotifier extends StateNotifier<PharmacieState> {
  final IPharmacieRepository _repository;
  final Ref _ref;

  PharmacieNotifier(this._repository, this._ref)
    : super(const PharmacieInitial());

  /// Charge les pharmacies les plus proches en fonction d'un groupe de garde
  Future<void> loadNearByPharmacie(int groupeGarde) async {
    // 1. Récupérer l'état actuel de la localisation
    //via la Référence (Ref) de Riverpod
    final locationState = _ref.read(locationProvider);

    if (locationState is! LocationSuccess) {
      state = const PharmacieError(
        "Impossible de charger les pharmacies : Position GPS manquante.",
      );
      return;
    }

    state = const PharmacieLoading();

    try {
      //Getting LatLng
      final latitude = locationState.position.latitude;
      final longitude = locationState.position.longitude;

      // Call repository to get pharmacieNearby
      final pharmacies = await _repository.getPharmaciesNearBy(
        latitude: latitude,
        longitude: longitude,
        groupeGarde: groupeGarde,
      );

      if (pharmacies.isEmpty) {
        state = const PharmacieError(
          "Aucune pharmacie de ce groupe n'a été trouvée à proximité.",
        );
      } else {
        state = PharmacieSuccess(pharmacies: pharmacies);
      }
    } catch (e) {
      state = PharmacieError(e.toString().replaceAll("Exception", ""));
    }
  }
}

// --- PROVIDER GLOBAL ---
final pharmacieProvider = StateNotifierProvider<PharmacieNotifier, PharmacieState>((
  ref,
) {
  // Récupération de l'implémentation du repository injectée par notre pharmacie_di_provider
  final repository = ref.watch(pharmacieRepositoryProvider);
  return PharmacieNotifier(repository, ref);
});
