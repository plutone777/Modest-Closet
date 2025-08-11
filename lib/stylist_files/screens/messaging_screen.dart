// lib/features/stylist/screens/messages_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // You need this for date formatting
import 'chat_detail_screen.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Handle case where user is not logged in
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: Text("Please log in to see messages.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), elevation: 1),
      body: StreamBuilder<QuerySnapshot>(
        // This is the new, correct stream.
        // It queries the 'chats' collection for any chat that includes the current user.
        stream:
            FirebaseFirestore.instance
                .collection('chats')
                .where('participants', arrayContains: currentUser.uid)
                .orderBy('lastMessageTimestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No client conversations yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder:
                (context, index) => const Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;

              // --- Logic to find the OTHER person in the chat ---
              final List<dynamic> participants = chatData['participants'];
              final String otherUserId = participants.firstWhere(
                (id) => id != currentUser.uid,
                orElse: () => '',
              );

              if (otherUserId.isEmpty) {
                // This is a safety check for corrupted data
                return const SizedBox.shrink();
              }

              // Get the other participant's details from the chat document
              final Map<String, dynamic> allParticipantInfo =
                  chatData['participantInfo'] ?? {};
              final Map<String, dynamic> otherUserInfo =
                  allParticipantInfo[otherUserId] ?? {};

              final name = otherUserInfo['name'] ?? 'Unknown User';
              final imageUrl = otherUserInfo['imageUrl'] ?? '';

              final lastMessage = chatData['lastMessage'] ?? '';
              final timestamp = chatData['lastMessageTimestamp'] as Timestamp?;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  // Format the timestamp to be readable
                  timestamp != null
                      ? DateFormat('h:mm a').format(timestamp.toDate())
                      : '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  // Navigate to the chat, passing the other user's details
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => ChatDetailScreen(
                            chatPartnerId: otherUserId,
                            chatPartnerName: name,
                            chatPartnerImageUrl: imageUrl,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
