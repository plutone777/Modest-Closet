import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('posts/${DateTime.now().millisecondsSinceEpoch}_${userId}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }

  Future<void> addPost({
    required String userId,
    required String imageUrl,
    required String description,
    required bool allowComments,
  }) async {
    try {
      await _firestore.collection("Posts").add({
        "userId": userId,
        "imageUrl": imageUrl,
        "description": description,
        "allowComments": allowComments,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add post: $e");
    }
  }
}
