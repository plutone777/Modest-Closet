import 'package:flutter/material.dart';
import 'package:mae_assignment/controllers/user_controller.dart';

class PostDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String description;
  final bool allowComments;
  final String userId;

  const PostDetailScreen({
    super.key,
    required this.imageUrl,
    required this.description,
    required this.allowComments,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final UserController _userController = UserController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userController.getUserById(userId), // ✅ Use controller method
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User not found"));
          }

          final userData = snapshot.data!;
          final username = userData['username'] ?? "Unknown";
          final profilePic = userData['profileIcon'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: profilePic != null ? NetworkImage(profilePic) : null,
                  child: profilePic == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(username),
              ),
              Image.network(imageUrl),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(description),
              ),
              if (allowComments) const Divider(),
            ],
          );
        },
      ),
    );
  }
}
