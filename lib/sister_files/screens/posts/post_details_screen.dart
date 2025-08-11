import 'package:flutter/material.dart';
import 'package:mae_assignment/sister_files/screens/posts/base_post_details_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;
  final String imageUrl;
  final String description;
  final bool allowComments;
  final String userId;

  const PostDetailScreen({
    super.key,
    required this.postId,
    required this.imageUrl,
    required this.description,
    required this.allowComments,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BasePostDetail(
      postId: postId,
      imageUrl: imageUrl,
      description: description,
      allowComments: allowComments,
      userId: userId,
    );
  }
}
