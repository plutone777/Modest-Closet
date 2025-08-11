import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'comments_list.dart';

class PostDetailDialog extends StatelessWidget {
  final String username;
  final String postId;
  final String? imageUrl;
  final String? description;
  final String? userId;
  final bool isStylist;

  const PostDetailDialog({
    super.key,
    required this.username,
    required this.postId,
    required this.imageUrl,
    required this.description,
    this.userId,
    this.isStylist = false,
  });

  Future<void> _sendNotification({
    required String userId,
    required String postId,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'type': 'post_deleted',
      'iconUrl': 'https://firebasestorage.googleapis.com/v0/b/mae-project-d86a2.appspot.com/o/notification_image%2FScreenshot%202025-08-02%20203245.png?alt=media',
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

  // Updated report post function (appends reason to list or creates if new)
  Future<void> _reportPost({
    required BuildContext context,
    required String postId,
    required String userId,
  }) async {
    final TextEditingController reasonController = TextEditingController();

    final bool? submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF9E7E9),
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
      String newReason = reasonController.text.trim();

      // Check if report for this post/userId exists
      final query = await FirebaseFirestore.instance
          .collection('ReportedPosts')
          .where('postId', isEqualTo: postId)
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
        await FirebaseFirestore.instance.collection('ReportedPosts').add({
          'postId': postId,
          'userId': userId,
          'reason': [newReason],
          'reportedAt': DateTime.now(),
          'status': 'pending',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Post reported!'),
          backgroundColor: const Color(0xFF412934),
        ),
      );
    }
  }

  // Updated report account function (appends reason to list or creates if new)
  Future<void> _reportAccount({
    required BuildContext context,
    required String userId,
    required String username,
  }) async {
    final TextEditingController reasonController = TextEditingController();

    final bool? submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF9E7E9),
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
      // Get the reported user's info
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      final userData = userDoc.exists ? userDoc.data() as Map<String, dynamic> : {};

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
          'username': username,
          'reason': [newReason],
          'reportedAt': DateTime.now(),
          'status': 'pending',
          // Add other user data for admin reference if needed
          'profileIcon': userData['profileIcon'] ?? '',
          'email': userData['email'] ?? '',
          'role': userData['role'] ?? '',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account reported!'),
          backgroundColor: const Color(0xFF412934),
        ),
      );
    }
  }

  Future<void> _handleDelete({
    required BuildContext context,
    required String postId,
    required String userId,
  }) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFFF9E7E9),
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
      await FirebaseFirestore.instance.collection('Posts').doc(postId).delete();
      await _sendNotification(userId: userId, postId: postId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Post deleted!'),
          backgroundColor: const Color(0xFF412934),
        ),
      );
      Navigator.of(context).pop(); // close the dialog after delete
    }
  }

  void _openCommentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF9E7E9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text(
                "Comments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF412934),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: CommentsList(
                  postId: postId,
                  postType: isStylist ? 'stylist' : 'sister',
                  scrollController: controller,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: isStylist ? const Color(0xFFFFF3F6) : const Color(0xFFFAE7E7),
      insetPadding: const EdgeInsets.all(0),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top bar with 3 dots, title, and close button
                Container(
                  color: const Color(0xFFD3A3AD),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                    title: Text("Report Post", style: TextStyle(color: Color(0xFF412934))),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      if (userId != null) {
                                        await _reportPost(
                                          context: context,
                                          postId: postId,
                                          userId: userId!,
                                        );
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.person_off_outlined, color: Color(0xFF412934)),
                                    title: Text("Report Account", style: TextStyle(color: Color(0xFF412934))),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      if (userId != null) {
                                        await _reportAccount(
                                          context: context,
                                          userId: userId!,
                                          username: username,
                                        );
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete_outline, color: Color(0xFF412934)),
                                    title: Text("Delete", style: TextStyle(color: Color(0xFF412934))),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      if (userId != null) {
                                        await _handleDelete(
                                          context: context,
                                          postId: postId,
                                          userId: userId!,
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
                      Expanded(
                        child: Center(
                          child: Text(
                            username,
                            style: const TextStyle(
                              color: Color(0xFF412934),
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF412934)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // (the rest of your dialog remains unchanged)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ... (unchanged: profile card, image, description, etc.)
                        if (isStylist && userId != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox();
                                  final stylist = snapshot.data!.data() as Map<String, dynamic>;
                                  return Container(
                                    margin: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 8),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(Icons.menu_book_rounded, color: Color(0xFF412934), size: 23),
                                            SizedBox(width: 8),
                                            Text(
                                              "Stylist Portfolio",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF412934),
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        if (stylist['username'] != null)
                                          Text("Name: ${stylist['username']}", style: TextStyle(color: Color(0xFF412934))),
                                        if (stylist['email'] != null)
                                          Text("Email: ${stylist['email']}", style: TextStyle(color: Color(0xFF412934))),
                                        if (stylist['bio'] != null)
                                          Text("Bio: ${stylist['bio']}", style: TextStyle(color: Color(0xFF412934))),
                                        if (stylist['phone'] != null)
                                          Text("Phone: ${stylist['phone']}", style: TextStyle(color: Color(0xFF412934))),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              // Book-style layout for image + description
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (imageUrl != null && imageUrl!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 18),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            imageUrl!,
                                            width: double.infinity,
                                            height: 230,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(height: 230, color: Colors.grey[200]),
                                          ),
                                        ),
                                      ),
                                    if (description != null && description!.isNotEmpty)
                                      Text(
                                        description!,
                                        style: const TextStyle(
                                          fontSize: 19,
                                          height: 1.7,
                                          color: Color(0xFF412934),
                                          fontFamily: "Georgia",
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        // ====== Sisters (original style) ======
                        if (!isStylist)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (imageUrl != null && imageUrl!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl!,
                                      width: double.infinity,
                                      height: 230,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(height: 230, color: Colors.grey[200]),
                                    ),
                                  ),
                                ),
                              if (description != null && description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                  child: Text(
                                    description!,
                                    style: const TextStyle(fontSize: 17, color: Color(0xFF412934)),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 44),
                        Padding(
                          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 8),
                          child: const Text(
                            "Comments",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF412934),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Center(
                          child: Text(
                            'Tap the message button below to view or add comments.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // FAB floating on the dialog, bottom right
            Positioned(
              bottom: 22,
              right: 22,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFD3A3AD),
                elevation: 2,
                onPressed: () => _openCommentsSheet(context),
                child: const Icon(Icons.message, color: Color(0xFF412934)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
