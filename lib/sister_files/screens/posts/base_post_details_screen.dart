import 'package:flutter/material.dart';
import 'package:mae_assignment/sister_files/controllers/report_controller.dart';
import 'package:mae_assignment/sister_files/controllers/upload_post_controller.dart';
import 'package:mae_assignment/sister_files/widgets/comments_section.dart';
import 'package:mae_assignment/sister_files/widgets/reusable_widgets.dart';
import 'package:mae_assignment/sister_files/screens/posts/comment_sheet.dart';
import 'package:mae_assignment/sister_files/controllers/comment_controller.dart';

class BasePostDetail extends StatelessWidget {
  final String postId;
  final String imageUrl;
  final String description;
  final bool isOwnPost;
  final bool allowComments;
  final String? userId;

  const BasePostDetail({
    super.key,
    required this.postId,
    required this.imageUrl,
    required this.description,
    this.isOwnPost = false,
    this.allowComments = true,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final UploadPostController _postController = UploadPostController();
    final CommentController _commentController = CommentController();
    final TextEditingController _descController = TextEditingController(
      text: description,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnPost ? "Your Post" : "Post Details"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
        actions: [
          if (isOwnPost)
            // Own post: edit/delete menu
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "edit") {
                  _showEditDialog(context, _descController, _postController);
                } else if (value == "delete") {
                  _confirmDelete(context, _postController);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: "edit",
                      child: Text("Edit Description"),
                    ),
                    const PopupMenuItem(
                      value: "delete",
                      child: Text("Delete Post"),
                    ),
                  ],
            )
          else
            // Other users' posts: report menu
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "report") {
                  _showReportDialog(context);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: "report",
                      child: Text(
                        "Report Post",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
            ),
        ],
      ),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Post Image
          Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover),

          // Description
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(description, style: const TextStyle(fontSize: 16)),
          ),

          if (allowComments) const Divider(),

          //  Comments Section
          if (allowComments)
            CommentsSection(postId: postId, allowComments: allowComments),
        ],
      ),

      // Add comment button only if comments are allowed & not own post
      bottomNavigationBar:
          (allowComments && !isOwnPost)
              ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomButton(
                  text: "Add Comment",
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder:
                          (context) => AddCommentSheet(
                            postId: postId,
                            commentController: _commentController,
                          ),
                    );
                  },
                ),
              )
              : null,
    );
  }

  // EDIT DESCRIPTION
  void _showEditDialog(
    BuildContext context,
    TextEditingController descController,
    UploadPostController postController,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Description"),
            content: TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter new description",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await postController.editPostDescription(
                    postId: postId,
                    newDescription: descController.text,
                    context: context,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  // DELETE POST
  void _confirmDelete(
    BuildContext context,
    UploadPostController postController,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Post"),
            content: const Text("Are you sure you want to delete this post?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await postController.deletePost(
                    postId: postId,
                    context: context,
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final ReportController _reportController = ReportController();
    String selectedReason = "Inappropriate Content";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Report Post"),
              content: DropdownButton<String>(
                value: selectedReason,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: "Inappropriate Content",
                    child: Text("Inappropriate Content"),
                  ),
                  DropdownMenuItem(value: "Spam", child: Text("Spam")),
                  DropdownMenuItem(
                    value: "Harassment",
                    child: Text("Harassment"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(
                      () => selectedReason = value,
                    ); 
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    await _reportController.reportPost(
                      postId: postId,
                      userId: userId ?? "unknown",
                      reason: selectedReason,
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Post reported for review."),
                      ),
                    );
                  },
                  child: const Text(
                    "Report",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
