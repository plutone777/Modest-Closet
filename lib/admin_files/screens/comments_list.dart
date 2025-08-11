import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsList extends StatefulWidget {
  final String postId;
  final String postType; // 'sister' or 'stylist'
  final ScrollController? scrollController;

  const CommentsList({
    super.key,
    required this.postId,
    this.postType = 'sister',
    this.scrollController,
  });

  @override
  State<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _internalScrollController = ScrollController();
  bool _isSending = false;

  // For admin commenting only, can be changed to dynamic
  final String adminName = "Admin";
  final String? adminAvatarUrl = null;

  CollectionReference get _commentsCollection {
    if (widget.postType == 'stylist') {
      return FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments');
    } else {
      return FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.postId)
          .collection('Comments');
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isSending = true);

    final now = DateTime.now();
    await _commentsCollection.add({
      'text': _commentController.text.trim(),
      'username': adminName,
      'profileIcon': adminAvatarUrl,
      'userId': "admin_id",
      'createdAt': now,
    });

    _commentController.clear();
    setState(() => _isSending = false);

    Future.delayed(const Duration(milliseconds: 200), () {
      final ctrl = widget.scrollController ?? _internalScrollController;
      if (ctrl.hasClients) {
        ctrl.animateTo(
          ctrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendCommentNotification({
    required String userId,
    required String postId,
    required String commentId,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'type': 'comment_deleted',
      'iconUrl':
          'https://firebasestorage.googleapis.com/v0/b/mae-project-d86a2.appspot.com/o/notification_image%2FScreenshot%202025-08-02%20203245.png?alt=media',
      'title': '📢 Comment Removed Due to Guideline Violation',
      'message': '''
Salam,

Your recent comment has been removed because it did not follow our community guidelines for modest content. We aim to ensure a safe, respectful space for all users, especially those practicing modest fashion.

If you believe this was a mistake or would like clarification, you can submit an appeal or review the [Community Guidelines].

Thank you for your understanding and continued support of Modest Closet 🌸

— Modest Closet Team
''',
      'postId': postId,
      'commentId': commentId,
      'createdAt': DateTime.now(),
      'read': false,
    });
  }

  Future<void> _reportComment({
    required BuildContext context,
    required String commentId,
    required String commentText,
    required String userId,
    required String postId,
  }) async {
    final TextEditingController reasonController = TextEditingController();

    final bool? submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF9E7E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          "Report Comment",
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

      // Check if report for this comment by this user already exists
      final query = await FirebaseFirestore.instance
          .collection('ReportedComments')
          .where('commentId', isEqualTo: commentId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Already exists, update the reasons list
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
        // No report exists for this user-comment, create a new one as a list
        await FirebaseFirestore.instance.collection('ReportedComments').add({
          'commentId': commentId,
          'commentText': commentText,
          'postId': postId,
          'userId': userId,
          'reason': [newReason],
          'reportedAt': DateTime.now(),
          'status': 'pending',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment reported!'),
          backgroundColor: Color(0xFF412934),
        ),
      );
    }
  }

  Future<void> _deleteComment({
    required BuildContext context,
    required String commentId,
    required String userId,
    required String postId,
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
                "Are you sure you want to delete this comment?",
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
      await _commentsCollection.doc(commentId).delete();
      await _sendCommentNotification(
        userId: userId,
        postId: postId,
        commentId: commentId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment deleted!'),
          backgroundColor: Color(0xFF412934),
        ),
      );
    }
  }

  // Widget to display avatar from comment or from user profile if missing
  Widget buildCommentAvatar(String? profileUrl, String? userId) {
    if (profileUrl != null && profileUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(profileUrl),
        radius: 17,
        backgroundColor: Colors.transparent,
      );
    }
    // If userId exists, try to fetch user profile icon from Users collection
    if (userId != null && userId.isNotEmpty) {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final userIcon = userData['profileIcon'];
            if (userIcon != null && userIcon.isNotEmpty) {
              return CircleAvatar(
                backgroundImage: NetworkImage(userIcon),
                radius: 17,
                backgroundColor: Colors.transparent,
              );
            }
          }
          return const CircleAvatar(
            backgroundColor: Color(0xFFFAE7E7),
            radius: 17,
            child: Icon(Icons.person, color: Color(0xFF412934), size: 20),
          );
        },
      );
    }
    // Fallback default avatar
    return const CircleAvatar(
      backgroundColor: Color(0xFFFAE7E7),
      radius: 17,
      child: Icon(Icons.person, color: Color(0xFF412934), size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.scrollController ?? _internalScrollController;

    return Column(
      children: [
        // --- Input Field for Admin ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Row(
            children: [
              if (adminAvatarUrl != null && adminAvatarUrl!.isNotEmpty)
                CircleAvatar(
                  backgroundImage: NetworkImage(adminAvatarUrl!),
                  radius: 18,
                  backgroundColor: Colors.transparent,
                )
              else
                const CircleAvatar(
                  backgroundColor: Color(0xFFD3A3AD),
                  radius: 18,
                  child: Icon(Icons.person, color: Color(0xFF412934), size: 20),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  maxLength: 5000,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "Add a comment...",
                    fillColor: Color(0xFFFAE7E7),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 15, color: Color(0xFF412934)),
                  enabled: !_isSending,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isSending
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF412934)))
                    : const Icon(Icons.send, color: Color(0xFF412934)),
                onPressed: _isSending ? null : _sendComment,
              )
            ],
          ),
        ),
        // --- Comments List ---
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _commentsCollection.orderBy('createdAt', descending: false).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF412934)));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No comments yet.",
                    style: TextStyle(color: Color(0xFF412934)),
                  ),
                );
              }

              final comments = snapshot.data!.docs;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (ctrl.hasClients) {
                  ctrl.jumpTo(ctrl.position.maxScrollExtent);
                }
              });

              return ListView.builder(
                controller: ctrl,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final doc = comments[index];
                  final commentId = doc.id;
                  final comment = doc.data() as Map<String, dynamic>;
                  final text = comment['text'] ?? '';
                  final username = comment['username'] ?? 'User';
                  final profileUrl = comment['profileIcon'];
                  final userId = comment['userId'];
                  final createdAtRaw = comment['createdAt'];
                  DateTime? createdAt;
                  if (createdAtRaw is Timestamp) {
                    createdAt = createdAtRaw.toDate();
                  } else if (createdAtRaw is DateTime) {
                    createdAt = createdAtRaw;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3A3AD),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildCommentAvatar(profileUrl, userId),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF412934),
                                  ),
                                ),
                                Text(
                                  text,
                                  style: const TextStyle(fontSize: 15, color: Color(0xFF412934)),
                                ),
                                if (createdAt != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} "
                                      "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF85565E)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Color(0xFF412934)),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => Container(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Comment Options",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF412934),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ListTile(
                                        leading: const Icon(Icons.flag_outlined, color: Color(0xFF412934)),
                                        title: const Text("Report", style: TextStyle(color: Color(0xFF412934))),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await _reportComment(
                                            context: context,
                                            commentId: commentId,
                                            commentText: text,
                                            userId: userId,
                                            postId: widget.postId,
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.delete_outline, color: Color(0xFF412934)),
                                        title: const Text("Delete", style: TextStyle(color: Color(0xFF412934))),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await _deleteComment(
                                            context: context,
                                            commentId: commentId,
                                            userId: userId,
                                            postId: widget.postId,
                                          );
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
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
