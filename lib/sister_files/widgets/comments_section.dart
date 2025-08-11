import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mae_assignment/sister_files/controllers/report_controller.dart';

class CommentsSection extends StatelessWidget {
  final String postId;
  final bool allowComments;

  const CommentsSection({
    super.key,
    required this.postId,
    required this.allowComments,
  });

  @override
  Widget build(BuildContext context) {
    final ReportController _reportController = ReportController();

    if (!allowComments) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .collection('Comments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, commentSnapshot) {
        if (commentSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!commentSnapshot.hasData || commentSnapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Center(child: Text("No comments yet.")),
          );
        }

        final comments = commentSnapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final commentDoc = comments[index];
            final comment = commentDoc.data() as Map<String, dynamic>;

            final commentText = comment['text'] ?? '';
            final commentUser = comment['username'] ?? 'Anonymous';
            final timestamp = comment['createdAt'] as Timestamp?;

            return GestureDetector(
              onLongPress: () {
                _showCommentOptions(
                  context,
                  postId,
                  commentDoc.id,
                  commentText,
                  _reportController,
                );
              },
              child: ListTile(
                leading: const Icon(Icons.comment, color: Colors.grey),
                title: Text(
                  commentUser,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(commentText),
                trailing: Text(
                  timestamp != null ? _formatTimestamp(timestamp) : '',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

void _showCommentOptions(BuildContext context, String postId, String commentId,
    String commentText, ReportController reportController) {
  showModalBottomSheet(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.red),
              title: const Text("Report Comment"),
              onTap: () async {
                Navigator.pop(sheetContext); 

                try {
                  await reportController.reportComment(
                    postId: postId,
                    commentId: commentId,
                    commentText: commentText,
                  );


                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Comment reported for review."),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to report: $e"),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text("Cancel"),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      );
    },
  );
}

}
