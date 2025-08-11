import 'package:flutter/material.dart';
import 'package:mae_assignment/sister_files/widgets/reusable_widgets.dart';
import 'package:mae_assignment/sister_files/controllers/comment_controller.dart';

class AddCommentSheet extends StatefulWidget {
  final String postId;
  final CommentController commentController;

  const AddCommentSheet({
    super.key,
    required this.postId,
    required this.commentController,
  });

  @override
  State<AddCommentSheet> createState() => _AddCommentSheetState();
}

class _AddCommentSheetState extends State<AddCommentSheet> {
  final TextEditingController _commentControllerText = TextEditingController();
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Add a Comment",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Comment Input
          TextField(
            controller: _commentControllerText,
            decoration: InputDecoration(
              hintText: "Write your comment here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 10),

          // Post Button
          _isPosting
              ? const CircularProgressIndicator()
              : CustomButton(
                  text: "Post Comment",
                  onPressed: () async {
                    if (_commentControllerText.text.trim().isEmpty) {
                      Navigator.pop(context);
                      return;
                    }

                    setState(() => _isPosting = true);

                    await widget.commentController.addComment(
                      widget.postId,
                      _commentControllerText.text,
                    );

                    setState(() => _isPosting = false);
                    Navigator.pop(context);
                  },
                ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
