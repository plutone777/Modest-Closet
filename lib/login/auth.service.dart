import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTER FUNCTION
  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('Users').doc(uid).set({
        'username': username,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // LOGIN FUNCTION
  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = userCredential.user!.uid;
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc['role']; 
      } else {
        return null; 
      }
    } on FirebaseAuthException catch (e) {
      return "error:${e.code}"; 
    }
  }

}
