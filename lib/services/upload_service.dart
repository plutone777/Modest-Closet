import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  Future<void> uploadItem({
    required String name,
    required String category,
    required String fabric,
    required String season,
    required String style,
    required File imageFile,
    required String userId
  }) async {
    // Upload image to Firebase Storage
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference storageRef = FirebaseStorage.instance.ref().child("clothes/$fileName");

    await storageRef.putFile(imageFile);
    String downloadUrl = await storageRef.getDownloadURL();

    // Save details to Firestore
    await FirebaseFirestore.instance.collection("Clothes").add({
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
}
