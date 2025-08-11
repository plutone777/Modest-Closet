// lib/features/stylist/screens/comments_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/stylist_models.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || currentUser == null) {
      return;
    }

    // Fetch the current user's details to stamp the comment
    final userDoc =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.uid)
            .get();
    final username = userDoc.data()?['username'] ?? 'Anonymous';
    final imageUrl = userDoc.data()?['profileImageUrl'] ?? '';

    // Create the new comment in the 'comments' subcollection of the post
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
          'text': text,
          'authorId': currentUser!.uid,
          'authorName': username,
          'authorImageUrl': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

    // Increment the commentCount on the parent post document
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({'commentCount': FieldValue.increment(1)});

    _commentController.clear();
    // Hide the keyboard
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Listen to the 'comments' subcollection for this specific post
              stream:
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return const Center(child: Text('Something went wrong.'));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Center(
                    child: Text('No comments yet. Be the first!'),
                  );

                final comments =
                    snapshot.data!.docs
                        .map((doc) => Comment.fromFirestore(doc))
                        .toList();

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(comment.authorImageUrl),
                      ),
                      title: Text(
                        comment.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(comment.text),
                      trailing: Text(
                        DateFormat('MMM d').format(comment.timestamp.toDate()),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildCommentComposer(),
        ],
      ),
    );
  }

  Widget _buildCommentComposer() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(currentUser?.photoURL ?? ''),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            IconButton(onPressed: _postComment, icon: const Icon(Icons.send)),
          ],
        ),
      ),
    );
  }
}
