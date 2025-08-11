import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRequestController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sends a chat request to a stylist
  Future<String> sendMessageRequest(String stylistId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return "User not logged in.";
    }

    try {

      final userDoc =
          await _firestore.collection('Users').doc(currentUser.uid).get();
      final userData = userDoc.data() ?? {};


      await _firestore.collection('client_requests').add({
        'fromUserId': currentUser.uid,
        'fromUsername': userData['username'] ?? 'Unknown User',
        'fromUserImageUrl': userData['profileIcon'] ?? '',
        'toUserId': stylistId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return "Message request sent!";
    } catch (e) {
      return "Failed to send request: $e";
    }
  }

  Future<void> createChatRoom({
    required String stylistId,
    required String clientId,
    required String stylistName,
    required String stylistImageUrl,
    required String clientName,
    required String clientImageUrl,
  }) async {
    try {
      final chatId = _generateChatId(stylistId, clientId);
      final chatDocRef = _firestore.collection('chats').doc(chatId);

      await chatDocRef.set({
        'participants': [stylistId, clientId],
        'participantInfo': {
          stylistId: {'name': stylistName, 'imageUrl': stylistImageUrl},
          clientId: {'name': clientName, 'imageUrl': clientImageUrl},
        },
        'lastMessage': '',
        'lastMessageSenderId': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }
  String _generateChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }
}
