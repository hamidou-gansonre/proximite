import 'package:proximite/features/pharmacie_map_guidance/domain/entities/pharmacie_entitie.dart';

abstract class PharmacieState {
  const PharmacieState();
}

class PharmacieInitial extends PharmacieState {
  const PharmacieInitial();
}

class PharmacieLoading extends PharmacieState {
  const PharmacieLoading();
}

class PharmacieSuccess extends PharmacieState {
  final List<PharmacieEntitie> pharmacies;

  PharmacieSuccess({required this.pharmacies});
}

class PharmacieError extends PharmacieState {
  final String message;
  const PharmacieError(this.message);
}
