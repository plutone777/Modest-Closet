import 'package:cloud_firestore/cloud_firestore.dart';

class FeedController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getPostsStream() {
    return _firestore
        .collection("Posts")
        .orderBy("createdAt", descending: true) 
        .snapshots();
  }
}
