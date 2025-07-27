import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mae_assignment/controllers/create_outfit_controller.dart';
import 'package:mae_assignment/data/closet_data.dart';
import 'package:mae_assignment/widgets/reusable_widgets.dart';

class CreateOutfitScreen extends StatefulWidget {
  final String userId;
  const CreateOutfitScreen({super.key, required this.userId});

  @override
  State<CreateOutfitScreen> createState() => _CreateOutfitScreenState();
}

class _CreateOutfitScreenState extends State<CreateOutfitScreen> {
  final CreateOutfitController _controller = CreateOutfitController();

  String selectedCategory = "All";
  String selectedSeason = ClosetData.seasons.first;
  String selectedStyle = ClosetData.styles.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Outfit"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomTextField(
              controller: _controller.outfitNameController,
              label: "Outfit Name",
              prefixIcon: Icons.checkroom,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: CustomDropdown(
              label: "Season for Outfit",
              value: selectedSeason,
              items: ClosetData.seasons,
              onChanged: (String? newValue) {
                setState(() => selectedSeason = newValue!);
              },
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: CustomDropdown(
              label: "Style for Outfit",
              value: selectedStyle,
              items: ClosetData.styles,
              onChanged: (String? newValue) {
                setState(() => selectedStyle = newValue!);
              },
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: CustomDropdown(
              label: "Filter by Category",
              value: selectedCategory,
              items: ["All", ...ClosetData.categories], 
              onChanged: (String? newValue) {
                setState(() => selectedCategory = newValue!);
              },
            ),
          ),

          const SizedBox(height: 10),


          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (selectedCategory == "All")
                  ? FirebaseFirestore.instance
                      .collection("Clothes")
                      .where("userId", isEqualTo: widget.userId)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection("Clothes")
                      .where("userId", isEqualTo: widget.userId)
                      .where("category", isEqualTo: selectedCategory)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final clothes = snapshot.data!.docs;

                if (clothes.isEmpty) {
                  return const CustomEmptyState(
                    message: "No clothes found. Add some items to your closet.",
                  );
                }

                return ListView.builder(
                  itemCount: clothes.length,
                  itemBuilder: (context, index) {
                    final item = clothes[index];
                    final itemId = item.id;
                    final isSelected = _controller.selectedItems.contains(itemId);

                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(item['imageUrl'])),
                      title: Text(item['name']),
                      subtitle: Text(item['category']),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() => _controller.toggleItemSelection(itemId));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: "Save Outfit",
              onPressed: () => _controller.saveOutfit(
                userId: widget.userId,
                context: context,
                season: selectedSeason,
                style: selectedStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
