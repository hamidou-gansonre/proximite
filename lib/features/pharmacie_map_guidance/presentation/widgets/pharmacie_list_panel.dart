import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/pharmacie_provider.dart';
import 'package:proximite/features/pharmacie_map_guidance/presentation/providers/pharmacie_state.dart';

class PharmacieListPanel extends ConsumerWidget {
  final VoidCallback onClose; // Callback pour fermer proprement le panneau
  const PharmacieListPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pharmacieState = ref.watch(pharmacieProvider);

    //if not success State
    if (pharmacieState is! PharmacieSuccess ||
        pharmacieState.pharmacies.isEmpty) {
      return const SizedBox.shrink();
    }

    final pharmacies = pharmacieState.pharmacies;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent <= notification.minExtent + 0.02) {
          onClose();
        }
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize:
            0.28, // Taille de départ (occupe ~28% de l'écran en bas)
        minChildSize: 0.15, // Taille minimale quand on le rabat
        maxChildSize: 0.70,
        snap: true, // Taille maximale quand on l'étire vers le haut
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            // On utilise un CustomScrollView pour combiner une entête fixe et une liste défilante
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                //Entete Fixe et Epingle
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  elevation: 0.5,
                  toolbarHeight: 75,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  title: Column(
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

                      // Titre et bouton de fermeture
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${pharmacies.length} pharmacies proches",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: onClose,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                //La listes des pharmacies
                SliverPadding(
                  padding: EdgeInsets.only(top: 8, bottom: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final pharmacie = pharmacies[index];
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
                          side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
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
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
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
                    }, childCount: pharmacies.length),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
