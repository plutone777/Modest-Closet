import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mae_assignment/screens/item_details_screen.dart';
import 'package:mae_assignment/widgets/reusable_buttons.dart';
import 'package:mae_assignment/widgets/reusable_widgets.dart';

class OutfitDetailScreen extends StatelessWidget {
  final String outfitName;
  final List<String> itemIds;

  const OutfitDetailScreen({
    super.key,
    required this.outfitName,
    required this.itemIds,
  });

  Future<List<Map<String, dynamic>>> _fetchClothingItems() async {
    List<Map<String, dynamic>> items = [];

    for (String id in itemIds) {
      final doc = await FirebaseFirestore.instance.collection("Clothes").doc(id).get();
      if (doc.exists && doc.data() != null) {
        items.add({...doc.data()!, 'id': id}); 
      }
    }
    return items;
  }

  Future<void> _deleteOutfit(BuildContext context) async {
    try {

      final snapshot = await FirebaseFirestore.instance
          .collection("Outfits")
          .where("name", isEqualTo: outfitName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Outfit deleted successfully")),
        );

        Navigator.pop(context); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Outfit not found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting outfit: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(outfitName),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchClothingItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const CustomEmptyState(message: "No items found for this outfit");
                }

                final items = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return ClothingCard(
                      imageUrl: item['imageUrl'],
                      name: item['name'],
                      category: item['category'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailScreen(
                              itemId: item['id'],
                              imageUrl: item['imageUrl'],
                              name: item['name'],
                              category: item['category'],
                              fabric: item['fabric'],
                              season: item['season'],
                              style: item['style'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // DELETE BUTTON
          DeleteButton(
            itemType: "Outfit",
            onDelete: () async {
              final snapshot = await FirebaseFirestore.instance
                  .collection("Outfits")
                  .where("name", isEqualTo: outfitName)
                  .limit(1)
                  .get();

              if (snapshot.docs.isNotEmpty) {
                await snapshot.docs.first.reference.delete();
              } else {
                throw Exception("Outfit not found");
              }
            },
          ),

        ],
      ),
    );
  }
}
