import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.pink[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(data['text']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _MessageInput(chatId: chatId, currentUserId: currentUserId),
        ],
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const _MessageInput({required this.chatId, required this.currentUserId});

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text.trim();

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
    final messageRef = chatRef.collection('messages').doc();

    await messageRef.set({
      'senderId': widget.currentUserId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await chatRef.update({
      'lastMessage': text,
      'lastMessageSenderId': widget.currentUserId,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color.fromARGB(255, 216, 166, 176)),
            onPressed: _sendMessage,
          )
        ],
      ),
    );
  }
}
