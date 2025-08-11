import 'package:cloud_firestore/cloud_firestore.dart';

class ReportController {
  // Report a comment
  Future<void> reportComment({
    required String postId,
    required String commentId,
    required String commentText,
  }) async {
    await FirebaseFirestore.instance.collection("ReportedComments").add({
      "postId": postId,
      "commentId": commentId,
      "commentText": commentText,
      "reason": "Inappropriate content",
      "reportedAt": FieldValue.serverTimestamp(),
      "status": "pending",
    });
  }

  // Report a post
  Future<void> reportPost({
    required String postId,
    required String userId,
    required String reason,
  }) async {
    await FirebaseFirestore.instance.collection("ReportedPosts").add({
      "postId": postId,
      "userId": userId,
      "reason": reason, 
      "reportedAt": FieldValue.serverTimestamp(),
      "status": "pending",
    });
  }
}
