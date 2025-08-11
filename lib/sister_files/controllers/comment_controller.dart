import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addComment(String postId, String text) async {
    if (text.trim().isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDoc = await _firestore.collection('Users').doc(currentUser.uid).get();
    final userData = userDoc.data() as Map<String, dynamic>? ?? {};

    await _firestore
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .add({
      'userId': currentUser.uid,
      'username': userData['username'] ?? 'Unknown',  
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return _firestore
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
