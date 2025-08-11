// lib/features/stylist/screens/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mae_assignment/stylist_files/theme/app_theme.dart';
import 'package:mae_assignment/stylist_files/theme/app_theme.dart';

import 'package:mae_assignment/stylist_files/models/stylist_models.dart';
import 'package:mae_assignment/stylist_files/screens/user_profile_screen.dart';
import 'package:mae_assignment/stylist_files/screens/comment_screen.dart';
import 'package:mae_assignment/stylist_files/screens/my_clients_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // All the helper functions from before are correct and remain unchanged.
  // ... (like, save, report, navigation functions) ...
  Future<void> _toggleLike(Post post) async {
    if (currentUser == null) return;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(post.id);
    final update =
        post.likedBy.contains(currentUser!.uid)
            ? {
              'likedBy': FieldValue.arrayRemove([currentUser!.uid]),
            }
            : {
              'likedBy': FieldValue.arrayUnion([currentUser!.uid]),
            };
    await postRef.update(update);
  }

  Future<void> _toggleSave(Post post) async {
    if (currentUser == null) return;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(post.id);
    final update =
        post.savedBy.contains(currentUser!.uid)
            ? {
              'savedBy': FieldValue.arrayRemove([currentUser!.uid]),
            }
            : {
              'savedBy': FieldValue.arrayUnion([currentUser!.uid]),
            };
    await postRef.update(update);
  }

  Future<void> _showReportDialog(Post post) async {
    final reasonController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Report Post'),
            content: TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: "Why are you reporting this post?",
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(c).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (reasonController.text.isNotEmpty) {
                    _reportPost(post, reasonController.text);
                    Navigator.of(c).pop();
                  }
                },
                child: const Text('Submit Report'),
              ),
            ],
          ),
    );
  }

  Future<void> _reportPost(Post post, String reason) async {
    if (currentUser == null) return;
    await FirebaseFirestore.instance.collection('ReportedPosts').add({
      'postId': post.id,
      'userId': currentUser!.uid,
      'reason': [reason],
      'reportedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post reported. Thank you.")),
      );
  }

  void _navigateToComments(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentsScreen(postId: postId)),
    );
  }

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If user is not logged in, we can't filter the feed, so show a message.
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Feed')),
        body: const Center(child: Text("Please log in to see the feed.")),
      );
    }

    // --- THIS IS THE CORRECTED QUERY ---
    // It fetches all posts where the authorId is NOT EQUAL to the current user's ID.
    final Stream<QuerySnapshot> feedStream =
        FirebaseFirestore.instance
            .collection('posts')
            .where(
              'authorId',
              isNotEqualTo: currentUser!.uid,
            ) // <-- THIS IS THE FIX
            .orderBy(
              'authorId',
            ) // Required by Firestore when using isNotEqualTo with orderBy
            .orderBy('timestamp', descending: true)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.handshake_outlined),
            tooltip: 'My Clients',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyClientsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: feedStream, // Use the new, filtered stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error loading feed: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text("No posts from other users yet."));

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final post = Post.fromFirestore(snapshot.data!.docs[index]);
              return _buildPostCard(post);
            },
          );
        },
      ),
    );
  }

  // The _buildPostCard widget is perfect and does not need any changes.
  Widget _buildPostCard(Post post) {
    // ... (rest of the code is unchanged and correct) ...
    final bool isLiked =
        currentUser != null && post.likedBy.contains(currentUser!.uid);
    final bool isSaved =
        currentUser != null && post.savedBy.contains(currentUser!.uid);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () => _navigateToUserProfile(post.authorId),
            leading: CircleAvatar(
              backgroundColor: AppTheme.dustyRose,
              backgroundImage:
                  post.authorImageUrl.isNotEmpty
                      ? NetworkImage(post.authorImageUrl)
                      : null,
              child:
                  post.authorImageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
            ),
            title: Text(
              post.authorName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.flag_outlined, color: AppTheme.mauve),
              tooltip: 'Report Post',
              onPressed: () => _showReportDialog(post),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Image.network(
              post.postImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
              loadingBuilder:
                  (context, child, p) =>
                      p == null
                          ? child
                          : const SizedBox(
                            height: 300,
                            child: Center(child: CircularProgressIndicator()),
                          ),
              errorBuilder:
                  (context, e, s) => const SizedBox(
                    height: 300,
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : AppTheme.mauve,
                  ),
                  onPressed: () => _toggleLike(post),
                ),
                Text(post.likeCount.toString()),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppTheme.mauve,
                  ),
                  onPressed: () => _navigateToComments(post.id),
                ),
                Text(post.commentCount.toString()),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: AppTheme.primaryMaroon,
                  ),
                  onPressed: () => _toggleSave(post),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${post.authorName} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: post.description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
