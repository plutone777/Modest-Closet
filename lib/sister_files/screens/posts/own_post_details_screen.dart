import 'package:flutter/material.dart';
import 'package:mae_assignment/sister_files/screens/posts/base_post_details_screen.dart';

class OwnPostDetailScreen extends StatelessWidget {
  final String postId;
  final String imageUrl;
  final String description;

  const OwnPostDetailScreen({
    super.key,
    required this.postId,
    required this.imageUrl,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return BasePostDetail(
      postId: postId,
      imageUrl: imageUrl,
      description: description,
      isOwnPost: true,  
      allowComments: true,
    );
  }
}
