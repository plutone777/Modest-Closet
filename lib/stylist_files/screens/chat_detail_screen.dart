// lib/features/stylist/screens/chat_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ChatDetailScreen extends StatefulWidget {
  final String chatPartnerId;
  final String chatPartnerName;
  final String chatPartnerImageUrl;

  const ChatDetailScreen({
    Key? key,
    required this.chatPartnerId,
    required this.chatPartnerName,
    required this.chatPartnerImageUrl,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late String _chatId;

  @override
  void initState() {
    super.initState();
    // Generate a consistent chat ID regardless of who starts the chat
    List<String> ids = [currentUser!.uid, widget.chatPartnerId];
    ids.sort(); // Sorts the list alphabetically
    _chatId = ids.join('_');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || currentUser == null) return;

    final messageText = text;
    _messageController.clear();

    final messageData = {
      'senderId': currentUser!.uid,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Use a batch write to send the message and update the chat summary
    final batch = FirebaseFirestore.instance.batch();

    // 1. Add the new message to the 'messages' subcollection
    final messageRef =
        FirebaseFirestore.instance
            .collection('chats')
            .doc(_chatId)
            .collection('messages')
            .doc();
    batch.set(messageRef, messageData);

    // 2. Update the main chat document with the last message info
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(_chatId);
    batch.set(chatRef, {
      'participants': [currentUser!.uid, widget.chatPartnerId],
      'participantInfo': {
        currentUser!.uid: {
          'name': currentUser!.displayName ?? 'My Name',
          'imageUrl': currentUser!.photoURL ?? '',
        },
        widget.chatPartnerId: {
          'name': widget.chatPartnerName,
          'imageUrl': widget.chatPartnerImageUrl,
        },
      },
      'lastMessage': messageText,
      'lastMessageSenderId': currentUser!.uid,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // Use merge to create if it doesn't exist

    await batch.commit();

    // Scroll to the bottom after sending
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatPartnerImageUrl),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Text(widget.chatPartnerName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(_chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Say hello!"));
                }

                // Automatically scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    return _buildMessageBubble(messageData);
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _sendMessage,
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData) {
    final bool isMe = messageData['senderId'] == currentUser!.uid;
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isMe ? Colors.black : Colors.grey.shade200,
            borderRadius:
                isMe
                    ? const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )
                    : const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
          ),
          child: Text(
            messageData['text'] ?? '',
            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
