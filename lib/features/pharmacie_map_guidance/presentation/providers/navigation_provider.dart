import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proximite/core/utils/html_parser.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/location_notifier.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/navigation_state.dart';

class NavigationNotifier extends StateNotifier<NavigationState> {
  final FlutterTts _tts = FlutterTts();
  final Ref _ref;

  StreamSubscription<Position>? _gpsSubscription;
  // Contiendra les étapes décodées de Google Directions
  List<dynamic> _routeSteps = [];

  NavigationNotifier(this._ref) : super(NavigationState()) {
    _initialiseTts();
  }

  /// Initialise le moteur vocal en Français
  Future<void> _initialiseTts() async {
    await _tts.setLanguage("fr-FR");
    await _tts.setSpeechRate(0.5); // Vitesse de parole normale
    await _tts.setVolume(1.0);
  }

  //function speaker
  Future<void> _speaker(String htmlText) async {
    // les balises <b> et <div> du texte renvoyé par Google avant de le passer au TTS.
    final String cleanedText = HtmlParser.cleanInstruction(htmlText);
    if (cleanedText.isNotEmpty) {
      await _tts.speak(cleanedText);
    }
  }

  /// Démarre le guidage pas-à-pas autonome
  void startGuiding(List<dynamic> googleStep) {
    _routeSteps = googleStep;
    state = NavigationState(
      isNavigating: true,
      indexNextStep: 0,
      currentInstruction: _routeSteps.isNotEmpty
          ? _routeSteps[0]['html_instructions']
          : "Suivez l'itinéraire",
    );

    // Énoncer la toute première instruction au démarrage
    _speaker(state.currentInstruction);

    // 1. on  S'abonne au flux GPS temps réel du LocationNotifier
    final locationNotifier = _ref.read(locationProvider.notifier);

    // Sécurité : annuler un ancien abonnement s'il existe
    _gpsSubscription?.cancel();
    _gpsSubscription = locationNotifier.fluxPosition.listen((
      Position position,
    ) {
      _analyseUserPosition(position);
    });
  }

  /// Arrête proprement le guidage et libère les capteurs
  void stopGuiding() {
    _gpsSubscription?.cancel();
    _tts.stop();
    state = NavigationState();
  }

  /// Algorithme de calcul de proximité avec les étapes de la route
  void _analyseUserPosition(Position position) {
    if (_routeSteps.isEmpty || state.indexNextStep >= _routeSteps.length) {
      return;
    }

    final step = _routeSteps[state.indexNextStep];
    final stepLat = step['end_location']['lat'] as double;
    final stepLng = step['end_location']['lng'] as double;

    // Calculer la distance métrique (en m) entre l'utilisateur et le point de virage
    double distanceMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      stepLat,
      stepLng,
    );

    // Si l'utilisateur est à moins de 15 mètres du virage, on passe à l'étape suivante !

    if (distanceMeters < 15) {
      int nextStep = state.indexNextStep + 1;

      if (nextStep < _routeSteps.length) {
        final nextInstruction =
            _routeSteps[nextStep]['html_instructions'] as String;

        state = state.copyWith(
          indexcurrentStep: nextStep,
          currentInstruction: nextInstruction,
        );

        // Le copilote parle !
        _speaker(nextInstruction);
      } else {
        // Arrivée à destination (la pharmacie)
        state = state.copyWith(
          currentInstruction:
              "Vous êtes arrivé à votre pharmacie de destination.",
        );
        _speaker(state.currentInstruction);
        stopGuiding(); // Et on Arrete le guidage
      }
    }
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    _tts.stop();
    super.dispose();
  }
}

//// --- PROVIDER GLOBAL ---
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier(ref);
    });
