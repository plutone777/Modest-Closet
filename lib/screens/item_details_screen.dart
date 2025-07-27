import 'package:flutter/material.dart';
import 'package:mae_assignment/widgets/reusable_widgets.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;
  final String imageUrl;
  final String name;
  final String category;
  final String? fabric;
  final String? season;
  final String? style;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
    required this.imageUrl,
    required this.name,
    required this.category,
    this.fabric,
    this.season,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              "Category: $category",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            if (fabric != null && fabric!.isNotEmpty)
              Text(
                "Fabric: $fabric",
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
            if (fabric != null && fabric!.isNotEmpty) const SizedBox(height: 8),

            if (season != null && season!.isNotEmpty)
              Text(
                "Season: $season",
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
            if (season != null && season!.isNotEmpty) const SizedBox(height: 8),

            if (style != null && style!.isNotEmpty)
              Text(
                "Style: $style",
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // EDIT BUTTON
                  CustomButton(
                    text: "Edit",
                    backgroundColor: Color.fromARGB(255, 216, 166, 176),
                    onPressed: () {
                      // Edit function will go here later
                    },
                  ),
                  const SizedBox(height: 10),

                  // DELETE BUTTON
                  CustomButton(
                    text: "Delete",
                    backgroundColor: Color.fromARGB(255, 121, 78, 89),
                    onPressed: () {
                      // Delete function will go here later
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
