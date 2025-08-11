// lib/features/stylist/screens/post_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:mae_assignment/stylist_files/models/stylist_models.dart';
import 'package:mae_assignment/stylist_files/widgets/post_card.dart'; // <-- IMPORT THE NEW WIDGET

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post")),
      body: SingleChildScrollView(
        // It now correctly calls the PostCard widget from its own file
        child: PostCard(post: post),
      ),
    );
  }
}
