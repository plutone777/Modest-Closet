import 'package:cloud_firestore/cloud_firestore.dart';

class FeedController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getPostsStream(String currentUserId) {
    return _firestore
        .collection("Posts")
        .where("userId", isNotEqualTo: currentUserId)
        .orderBy("userId")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserPostsStream(String userId) {
    return _firestore
        .collection("Posts")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getStylistPostsStream() {
    return _firestore
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
}
