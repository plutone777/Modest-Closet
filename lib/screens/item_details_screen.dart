import 'package:flutter/material.dart';

class ItemDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String category;
  final String? fabric;
  final String? season;
  final String? style;

  const ItemDetailScreen({
    super.key,
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
        title: Text(name),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ Image at the top
            Image.network(
              imageUrl,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // ✅ Item details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(category, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 12),
                  if (fabric != null) Text("Fabric: $fabric", style: const TextStyle(fontSize: 16)),
                  if (season != null) Text("Season: $season", style: const TextStyle(fontSize: 16)),
                  if (style != null) Text("Style: $style", style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
