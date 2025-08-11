import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get notifications for the current user
  Stream<QuerySnapshot> getUserNotifications() {
    final String userId = _auth.currentUser!.uid;

    return _firestore
        .collection('notifications') 
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> markAsRead(String notifId) async {
    await _firestore.collection('notifications').doc(notifId).update({
      'read': true,
    });
  }
}
