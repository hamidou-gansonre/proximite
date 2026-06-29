import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximite/core/di/injection_container.dart';
import 'package:proximite/features/pharmacie_map_guidance/data/data_sources/pharmacie_api_datasource.dart';
import 'package:proximite/features/pharmacie_map_guidance/data/repositories/pharmacie_repository_impl.dart';
import 'package:proximite/features/pharmacie_map_guidance/domain/entities/repositories/i_pharmacie_repository.dart';

//Api provider
final pharmacieApiClientProvider = Provider<PharmacieApiDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return PharmacieApiDataSource(dio: dio);
});

// Provider pour le Repository (on expose l'interface abstraite)
final pharmacieRepositoryProvider = Provider<IPharmacieRepository>((ref) {
  final apiClient = ref.watch(pharmacieApiClientProvider);
  return PharmacieRepositoryImpl(apiClient: apiClient);
});
