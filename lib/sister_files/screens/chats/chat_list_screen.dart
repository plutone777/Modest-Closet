import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatting_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Chats")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser.uid)
            .orderBy('lastMessageTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chats yet"));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>;

              final participants = List<String>.from(data['participants']);
              final otherUserId = participants.firstWhere((id) => id != currentUser.uid);
              final otherUserInfo = (data['participantInfo'] ?? {})[otherUserId] ?? {};

              final name = otherUserInfo['name'] ?? 'Unknown';
              final imageUrl = otherUserInfo['imageUrl'] ?? '';
              final lastMessage = data['lastMessage']?.toString().trim();

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(name),
                subtitle: Text(
                  (lastMessage != null && lastMessage.isNotEmpty)
                      ? lastMessage
                      : 'Start chatting…',
                  style: TextStyle(
                    color: (lastMessage == null || lastMessage.isEmpty)
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chat.id,
                        currentUserId: currentUser.uid,
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
