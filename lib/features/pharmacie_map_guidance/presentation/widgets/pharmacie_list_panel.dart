import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/pharmacie_provider.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/pharmacie_state.dart';

class PharmacieListPanel extends ConsumerWidget {
  const PharmacieListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pharmacieState = ref.watch(pharmacieProvider);

    //if not success State
    if (pharmacieState is! PharmacieSuccess ||
        pharmacieState.pharmacies.isEmpty) {
      return const SizedBox.shrink();
    }

    final pharmacies = pharmacieState.pharmacies;

    return DraggableScrollableSheet(
      initialChildSize:
          0.28, // Taille de départ (occupe ~28% de l'écran en bas)
      minChildSize: 0.15, // Taille minimale quand on le rabat
      maxChildSize: 0.70, // Taille maximale quand on l'étire vers le haut
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Petite barre supérieure pour indiquer qu'on peut glisser le panneau
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      "${pharmacies.length} pharmacies trouvées",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(thickness: 0.5),

              //Liste déroulante des pharmacies
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: pharmacies.length,
                  itemBuilder: (context, index) {
                    final pharmacie = pharmacies[index];

                    // Formatage de la distance récupérée depuis ton backend Neon
                    // distanceKm est déjà calculée par PostgreSQL !

                    final distance = pharmacie.distanceKm >= 1.0
                        ? "${pharmacie.distanceKm.toStringAsFixed(1)} km"
                        : "${(pharmacie.distanceKm * 1000).toStringAsFixed(0)} m";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade200, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: Icon(
                            Icons.local_pharmacy,
                            color: Colors.green.shade700,
                          ),
                        ),
                        title: Text(
                          pharmacie.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Secteur : ${pharmacie.secteur}"),
                              if (pharmacie.telephone.isNotEmpty)
                                Text(
                                  "Tél : ${pharmacie.telephone}",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                        ),

                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            //Badge de distance
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                distance,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // TODO: Prochaine étape -> recentrer la carte ou lancer l'itinéraire au clic !
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
