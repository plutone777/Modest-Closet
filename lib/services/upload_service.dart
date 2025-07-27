import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a new item
  Future<void> uploadItem({
    required String name,
    required String category,
    required String fabric,
    required String season,
    required String style,
    required File imageFile,
    required String userId,
  }) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = _storage.ref("clothes/$fileName").putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    await _firestore.collection("Clothes").add({
      "name": name,
      "category": category,
      "fabric": fabric,
      "season": season,
      "style": style,
      "imageUrl": downloadUrl,
      "userId": userId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  //  Update an existing item
  Future<void> updateItem({
    required String itemId,
    required String name,
    required String category,
    required String fabric,
    required String season,
    required String style,
    File? newImageFile,
  }) async {
    try {
      final docRef = _firestore.collection("Clothes").doc(itemId);

      String? newImageUrl;

      if (newImageFile != null) {
        String fileName = "${itemId}_${DateTime.now().millisecondsSinceEpoch}";
        UploadTask uploadTask = _storage.ref("clothes/$fileName").putFile(newImageFile);
        TaskSnapshot snapshot = await uploadTask;
        newImageUrl = await snapshot.ref.getDownloadURL();
      }

      Map<String, dynamic> updatedData = {
        "name": name,
        "category": category,
        "fabric": fabric,
        "season": season,
        "style": style,
      };

      if (newImageUrl != null) {
        updatedData["imageUrl"] = newImageUrl;
      }

      await docRef.update(updatedData);
    } catch (e) {
      throw Exception("Failed to update item: $e");
    }
  }

  // Delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      final docRef = _firestore.collection("Clothes").doc(itemId);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception("Item not found");
      }

      final imageUrl = docSnapshot.data()?["imageUrl"];

      await docRef.delete();

      if (imageUrl != null && imageUrl.isNotEmpty) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      throw Exception("Failed to delete item: $e");
    }
  }


}
