import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateOutfitController {
  final TextEditingController outfitNameController = TextEditingController();
  final List<String> selectedItems = [];

  void toggleItemSelection(String itemId) {
    if (selectedItems.contains(itemId)) {
      selectedItems.remove(itemId);
    } else {
      selectedItems.add(itemId);
    }
  }

  Future<void> saveOutfit({
    required String userId,
    required BuildContext context,
    required String season,
    required String style,
  }) async {
    if (outfitNameController.text.isEmpty || selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name and select at least one item.")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("Outfits").add({
      "name": outfitNameController.text,
      "userId": userId,
      "items": selectedItems,
      "season": season,
      "style": style,
      "createdAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Outfit saved!")),
    );

    Navigator.pop(context);
  }
}
