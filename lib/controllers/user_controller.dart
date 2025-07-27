// controllers/user_controller.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // STREAM - Live user profile updates
  Stream<DocumentSnapshot> getUserProfileStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    return _firestore.collection("Users").doc(uid).snapshots();
  }

  // Fetch user details once
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection("Users").doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String username,
    required String email,
    String? password,
    File? profileImage,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    try {
      // Update username
      await _firestore.collection("Users").doc(uid).update({
        "username": username,
      });

      // Update email
      if (email != _auth.currentUser?.email) {
        await _auth.currentUser?.updateEmail(email);
        await _firestore.collection("Users").doc(uid).update({"email": email});
      }

      // Update password
      if (password != null && password.isNotEmpty) {
        await _auth.currentUser?.updatePassword(password);
      }

      // Upload profile image
      if (profileImage != null) {
        final ref = _storage.ref().child("profile_icons/$uid.jpg");
        await ref.putFile(profileImage);
        final downloadUrl = await ref.getDownloadURL();
        await _firestore.collection("Users").doc(uid).update({
          "profileIcon": downloadUrl,
        });
      }
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

    Future<Map<String, dynamic>?> getUserById(String userId) async {
      try {
        final doc = await _firestore.collection("Users").doc(userId).get();
        return doc.exists ? doc.data() : null;
      } catch (e) {
        print("Error fetching user by ID: $e");
        return null;
      }
    }


}
