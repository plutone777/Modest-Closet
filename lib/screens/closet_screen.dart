import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mae_assignment/screens/item_details_screen.dart';
import 'upload_item_screen.dart';
import 'package:mae_assignment/widgets/reusable_widgets.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  final List<String> categories = ["All", "Tops", "Bottoms", "Shoes", "Hijabs", "Accessories"];
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Closet"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // ✅ Use CustomDropdown instead of a hardcoded DropdownButtonFormField
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomDropdown(
              label: "Filter by Category",
              value: selectedCategory,
              items: categories,
              onChanged: (String? value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
          ),

          // ✅ Clothes List (Filtered)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (selectedCategory == "All")
                  ? FirebaseFirestore.instance
                      .collection("Clothes")
                      .where("userId", isEqualTo: userId)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection("Clothes")
                      .where("userId", isEqualTo: userId)
                      .where("category", isEqualTo: selectedCategory)
                      .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const CustomEmptyState(
                    message: "Something went wrong!",
                    icon: Icons.error,
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return CustomEmptyState(
                    message: selectedCategory == "All"
                        ? "Your closet is empty!\nClick + to add clothes."
                        : "No items found in $selectedCategory!",
                  );
                }

                final clothes = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: clothes.length,
                  itemBuilder: (context, index) {
                    final item = clothes[index];
                    return ClothingCard(
                      imageUrl: item['imageUrl'],
                      name: item['name'],
                      category: item['category'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailScreen(
                              itemId: item.id,
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
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadItemScreen(userId: userId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
