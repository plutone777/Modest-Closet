import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_detail_dialog.dart';
import 'constants.dart';
import '../widgets/read_more_text.dart';

class AdminFeedPage extends StatelessWidget {
  const AdminFeedPage({super.key});

  Future<void> _toggleLike({
    required String collection,
    required String postId,
    required String userId,
    required bool isLiked,
  }) async {
    final postRef = FirebaseFirestore.instance.collection(collection).doc(postId);
    await postRef.update({
      'likedBy': isLiked
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> _sendNotification({
    required String userId,
    required String postId,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'type': 'post_deleted',
      'iconUrl':
          'https://firebasestorage.googleapis.com/v0/b/mae-project-d86a2.appspot.com/o/notification_image%2FScreenshot%202025-08-02%20203245.png?alt=media',
      'title': '📢 Post Removed Due to Guideline Violation',
      'message': '''
Salam,

Your recent post has been removed because it did not follow our community guidelines for modest content. We aim to ensure a safe, respectful space for all users, especially those practicing modest fashion.

If you believe this was a mistake or would like clarification, you can submit an appeal or review the [Community Guidelines].

Thank you for your understanding and continued support of Modest Closet 🌸

— Modest Closet Team
''',
      'postId': postId,
      'createdAt': DateTime.now(),
      'read': false,
    });
  }

  Future<void> _reportPost({
    required BuildContext context,
    required String postId,
    required String userId,
  }) async {
    final TextEditingController reasonController = TextEditingController();
    final bool? submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: sisterColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          "Report Post",
          style: TextStyle(color: Color(0xFF412934), fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: reasonController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: "Reason for reporting...",
            hintStyle: TextStyle(color: Color(0xFF85565E)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF412934)),
            ),
          ),
          style: const TextStyle(color: Color(0xFF412934)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFD3A3AD),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.of(ctx).pop(true);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF412934),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Done"),
          ),
        ],
      ),
    );

    if (submitted == true && reasonController.text.trim().isNotEmpty) {
      // Check if report for this post/userId exists
      final query = await FirebaseFirestore.instance
          .collection('ReportedPosts')
          .where('postId', isEqualTo: postId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      String newReason = reasonController.text.trim();

      if (query.docs.isNotEmpty) {
        // If exists, update the list of reasons (no duplicates)
        final doc = query.docs.first;
        List<dynamic> reasons = [];
        if (doc.data().containsKey('reason')) {
          final prev = doc['reason'];
          if (prev is List) {
            reasons = List<String>.from(prev);
          } else if (prev is String && prev.isNotEmpty) {
            reasons = [prev];
          }
        }
        if (!reasons.contains(newReason)) {
          reasons.add(newReason);
        }
        await doc.reference.update({'reason': reasons, 'reportedAt': DateTime.now()});
      } else {
        // If not, create a new report with reasons as a list
        await FirebaseFirestore.instance.collection('ReportedPosts').add({
          'postId': postId,
          'userId': userId,
          'reason': [newReason],
          'reportedAt': DateTime.now(),
          'status': 'pending',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post reported!'),
          backgroundColor: Color(0xFF412934),
        ),
      );
    }
  }

  Future<void> _reportAccount({
    required BuildContext context,
    required String userId,
  }) async {
    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account not found!'),
          backgroundColor: Color(0xFF412934),
        ),
      );
      return;
    }
    final userData = userDoc.data() as Map<String, dynamic>;
    final TextEditingController reasonController = TextEditingController();

    final bool? submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: sisterColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          "Report Account",
          style: TextStyle(color: Color(0xFF412934), fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: reasonController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: "Reason for reporting this account...",
            hintStyle: TextStyle(color: Color(0xFF85565E)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF412934)),
            ),
          ),
          style: const TextStyle(color: Color(0xFF412934)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFD3A3AD),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.of(ctx).pop(true);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF412934),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Done"),
          ),
        ],
      ),
    );

    if (submitted == true && reasonController.text.trim().isNotEmpty) {
      String newReason = reasonController.text.trim();
      // Check if report for this account exists
      final query = await FirebaseFirestore.instance
          .collection('Reportedaccounts')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        List<dynamic> reasons = [];
        if (doc.data().containsKey('reason')) {
          final prev = doc['reason'];
          if (prev is List) {
            reasons = List<String>.from(prev);
          } else if (prev is String && prev.isNotEmpty) {
            reasons = [prev];
          }
        }
        if (!reasons.contains(newReason)) {
          reasons.add(newReason);
        }
        await doc.reference.update({'reason': reasons, 'reportedAt': DateTime.now()});
      } else {
        await FirebaseFirestore.instance.collection('Reportedaccounts').add({
          'userId': userId,
          'reason': [newReason],
          'reportedAt': DateTime.now(),
          'status': 'pending',
          'username': userData['username'] ?? '',
          'email': userData['email'] ?? '',
          'profileIcon': userData['profileIcon'] ?? '',
          'role': userData['role'] ?? '',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account reported!'),
          backgroundColor: Color(0xFF412934),
        ),
      );
    }
  }

  void _showLikersDialog(BuildContext context, List<dynamic> likedBy) async {
    if (likedBy.isEmpty) return;

    final userSnapshots = await Future.wait(
      likedBy.map((id) =>
          FirebaseFirestore.instance.collection('Users').doc(id).get()),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: sisterColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text("Liked by (${likedBy.length})",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF412934))),
        content: SizedBox(
          width: 300,
          height: 300,
          child: ListView.builder(
            itemCount: userSnapshots.length,
            itemBuilder: (context, i) {
              final user = userSnapshots[i];
              if (!user.exists) return SizedBox();
              final data = user.data() as Map<String, dynamic>;
              final avatar = data['profileIcon'] as String?;
              final name = data['username'] as String? ?? likedBy[i];
              return ListTile(
                leading: (avatar != null && avatar.isNotEmpty)
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(avatar),
                        radius: 19,
                        backgroundColor: Colors.transparent,
                      )
                    : const CircleAvatar(
                        backgroundColor: Color(0xFFD3A3AD),
                        radius: 19,
                        child: Icon(Icons.person, color: Color(0xFF412934)),
                      ),
                title: Text(name, style: const TextStyle(color: Color(0xFF412934))),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Color(0xFF412934))),
          )
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllPosts() async {
    final sistersSnap = await FirebaseFirestore.instance
        .collection('Posts')
        .orderBy('createdAt', descending: true)
        .get();

    final stylistsSnap = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .get();

    final posts = <Map<String, dynamic>>[];

    for (final doc in sistersSnap.docs) {
      final data = doc.data();
      data['__id'] = doc.id;
      data['__type'] = 'sister';
      posts.add(data);
    }
    for (final doc in stylistsSnap.docs) {
      final data = doc.data();
      data['__id'] = doc.id;
      data['__type'] = 'stylist';
      posts.add(data);
    }

    posts.sort((a, b) {
      final aTime = a['createdAt'] ?? a['timestamp'];
      final bTime = b['createdAt'] ?? b['timestamp'];
      return (bTime as Timestamp).compareTo(aTime as Timestamp);
    });

    return posts;
  }

  @override
  Widget build(BuildContext context) {
    const String adminUserId = 'admin_id';

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchAllPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF412934)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text("No posts found.", style: TextStyle(color: Color(0xFF412934))));
        }

        final posts = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final data = posts[index];
            final postId = data['__id'] as String;
            final postType = data['__type'] as String;

            final sisterUserId = data['userId'];
            final sisterDescription = data['description'];
            final sisterImageUrl = data['imageUrl'];
            final sisterLikedBy = data['likedBy'] as List<dynamic>? ?? [];

            final stylistUserId = data['authorId'];
            final stylistDescription = data['description'];
            final stylistImageUrl = data['postImageUrl'];
            final stylistLikedBy = data['likedBy'] as List<dynamic>? ?? [];

            final userId = postType == 'sister' ? sisterUserId : stylistUserId;
            final description = postType == 'sister' ? sisterDescription : stylistDescription;
            final imageUrl = postType == 'sister' ? sisterImageUrl : stylistImageUrl;
            final likedBy = postType == 'sister' ? sisterLikedBy : stylistLikedBy;
            final createdAt = (data['createdAt'] ?? data['timestamp']) as Timestamp?;
            final cardColor = postType == 'sister' ? sisterColor : stylistColor;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
              builder: (context, userSnapshot) {
                String? profileUrl;
                String? username;

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userMap = userSnapshot.data!.data() as Map<String, dynamic>;
                  profileUrl = userMap['profileIcon'] as String?;
                  username = userMap['username'] ?? userId;
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(postType == 'sister' ? 'Posts' : 'posts')
                      .doc(postId)
                      .snapshots(),
                  builder: (context, likeSnap) {
                    var likedByLive = likedBy;
                    if (likeSnap.hasData && likeSnap.data!.exists) {
                      final post = likeSnap.data!.data() as Map<String, dynamic>;
                      likedByLive = (post['likedBy'] as List<dynamic>?) ?? [];
                    }
                    final isLiked = likedByLive.contains(adminUserId);

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => PostDetailDialog(
                            username: username ?? userId ?? '',
                            postId: postId,
                            imageUrl: imageUrl,
                            description: description,
                            userId: userId,
                            isStylist: postType == 'stylist',
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: (profileUrl != null && profileUrl.isNotEmpty)
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(profileUrl),
                                      radius: 22,
                                      backgroundColor: Colors.transparent,
                                    )
                                  : const CircleAvatar(
                                      backgroundColor: Color(0xFFD3A3AD),
                                      radius: 22,
                                      child: Icon(Icons.person, color: Color(0xFF412934)),
                                    ),
                              title: Text(
                                username ?? userId,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, color: Color(0xFF412934)),
                              ),
                              subtitle: createdAt != null
                                  ? Text(
                                      "${createdAt.toDate().year}-${createdAt.toDate().month.toString().padLeft(2, '0')}-${createdAt.toDate().day.toString().padLeft(2, '0')} "
                                      "${createdAt.toDate().hour.toString().padLeft(2, '0')}:${createdAt.toDate().minute.toString().padLeft(2, '0')}",
                                      style: const TextStyle(color: Color(0xFF412934)),
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _toggleLike(
                                      collection: postType == 'sister' ? 'Posts' : 'posts',
                                      postId: postId,
                                      userId: adminUserId,
                                      isLiked: isLiked,
                                    ),
                                    onLongPress: () => _showLikersDialog(context, likedByLive),
                                    child: Row(
                                      children: [
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 200),
                                          transitionBuilder: (child, anim) =>
                                              ScaleTransition(scale: anim, child: child),
                                          child: Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            key: ValueKey(isLiked),
                                            color: isLiked
                                                ? Colors.redAccent
                                                : const Color(0xFF412934),
                                          ),
                                        ),
                                        if (likedByLive.isNotEmpty) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            "${likedByLive.length}",
                                            style: TextStyle(
                                              color: isLiked
                                                  ? Colors.redAccent
                                                  : Color(0xFF412934),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert, color: Color(0xFF412934)),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) => Container(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Post Options",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Color(0xFF412934),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              ListTile(
                                                leading: Icon(Icons.flag_outlined, color: Color(0xFF412934)),
                                                title: Text("Report", style: TextStyle(color: Color(0xFF412934))),
                                                onTap: () async {
                                                  Navigator.pop(context);
                                                  await _reportPost(
                                                    context: context,
                                                    postId: postId,
                                                    userId: userId,
                                                  );
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.person_off_outlined, color: Color(0xFF412934)), // Changed Icon
                                                title: Text("Report Account", style: TextStyle(color: Color(0xFF412934))),
                                                onTap: () async {
                                                  Navigator.pop(context);
                                                  await _reportAccount(
                                                    context: context,
                                                    userId: userId,
                                                  );
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.delete_outline, color: Color(0xFF412934)),
                                                title: Text("Delete", style: TextStyle(color: Color(0xFF412934))),
                                                onTap: () async {
                                                  Navigator.pop(context);
                                                  bool? confirmed = await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) => Dialog(
                                                      backgroundColor: sisterColor,
                                                      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 180),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(18),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(20),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            const Text(
                                                              "Are you sure you want to delete this post?",
                                                              style: TextStyle(
                                                                color: Color(0xFF412934),
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 17,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                            const SizedBox(height: 24),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.of(ctx).pop(false),
                                                                  style: TextButton.styleFrom(
                                                                    backgroundColor: const Color(0xFFD3A3AD),
                                                                    foregroundColor: Colors.white,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                  ),
                                                                  child: const Text(
                                                                    "Cancel",
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () => Navigator.of(ctx).pop(true),
                                                                  style: TextButton.styleFrom(
                                                                    backgroundColor: const Color(0xFF412934),
                                                                    foregroundColor: Colors.white,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                  ),
                                                                  child: const Text(
                                                                    "Delete",
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                  if (confirmed == true) {
                                                    final collection = postType == 'sister' ? 'Posts' : 'posts';
                                                    await FirebaseFirestore.instance.collection(collection).doc(postId).delete();
                                                    await _sendNotification(
                                                      userId: userId,
                                                      postId: postId,
                                                    );
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Post deleted!'),
                                                        backgroundColor: Color(0xFF412934),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (imageUrl != null && imageUrl.toString().isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(height: 200, color: Colors.grey[200]),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ReadMoreText(
                                text: description ?? '',
                                maxLines: 3,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF412934)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
