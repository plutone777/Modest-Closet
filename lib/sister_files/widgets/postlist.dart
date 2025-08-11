import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mae_assignment/sister_files/screens/posts/post_details_screen.dart';
import 'package:mae_assignment/sister_files/widgets/reusable_widgets.dart';
class PostList extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final String emptyMessage;
  final IconData emptyIcon;

  const PostList({
    super.key,
    required this.stream,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return CustomEmptyState(
            message: emptyMessage,
            icon: emptyIcon,
          );
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final data = post.data() as Map<String, dynamic>;


            final imageUrl = data.containsKey('postImageUrl')
                ? data['postImageUrl']
                : data['imageUrl'];

            final userId = data.containsKey('authorId')
                ? data['authorId']
                : data['userId'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(
                      imageUrl: imageUrl,
                      description: data['description'] ?? '',
                      allowComments: data['allowComments'] ?? true,
                      userId: userId,
                      postId: post.id,
                    ),
                  ),
                );
              },
              child: PostCard(
                imageUrl: imageUrl,
                description: data['description'] ?? '',
                allowComments: data['allowComments'] ?? true,
                userId: userId,
              ),
            );
          },
        );
      },
    );
  }
}
