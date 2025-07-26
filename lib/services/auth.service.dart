// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new user
  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // 🔹 Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔹 Get the UID of the new user
      String uid = userCredential.user!.uid;

      // 🔹 Save user details in Firestore (Users collection)
      await _firestore.collection('Users').doc(uid).set({
        'username': username,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message; // return error message
    } catch (e) {
      return e.toString();
    }
  }
}
