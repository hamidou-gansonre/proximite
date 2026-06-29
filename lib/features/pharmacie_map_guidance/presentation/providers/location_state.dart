import 'package:geolocator/geolocator.dart';

abstract class LocationState {
  const LocationState();
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationSuccess extends LocationState {
  final Position position ;
  const LocationSuccess(this.position);
}

class LocationError extends LocationState {
  final String message ;

  LocationError({required this.message});
  
}