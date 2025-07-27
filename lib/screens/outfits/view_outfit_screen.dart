import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mae_assignment/screens/outfits/outfit_details_screen.dart';
import 'package:mae_assignment/widgets/reusable_widgets.dart';

class OutfitListScreen extends StatelessWidget {
  final String userId;
  const OutfitListScreen({super.key, required this.userId});

  Future<List<String>> _fetchItemImages(List<dynamic> itemIds) async {
    final List<String> imageUrls = [];

    for (String itemId in itemIds) {
      final doc =
          await FirebaseFirestore.instance
              .collection("Clothes")
              .doc(itemId)
              .get();
      if (doc.exists && doc.data() != null) {
        imageUrls.add(doc['imageUrl']);
      }
    }

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Outfits"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("Outfits")
                .where("userId", isEqualTo: userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No outfits saved yet!"));
          }

          final outfits = snapshot.data!.docs;

          return ListView.builder(
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              final outfitName = outfit['name'];
              final List<dynamic> itemIds = outfit['items'];

              return FutureBuilder<List<String>>(
                future: _fetchItemImages(itemIds),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final imageUrls = snapshot.data ?? [];

                  return OutfitCard(
                    outfitName: outfitName,
                    imageUrls: imageUrls,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => OutfitDetailScreen(
                                outfitName: outfitName,
                                itemIds: List<String>.from(itemIds),
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
