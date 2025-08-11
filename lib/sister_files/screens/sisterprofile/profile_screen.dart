import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mae_assignment/sister_files/controllers/user_controller.dart';
import 'package:mae_assignment/sister_files/controllers/feed_controller.dart';
import 'package:mae_assignment/sister_files/screens/notifications_screen.dart';
import 'package:mae_assignment/sister_files/screens/posts/own_post_details_screen.dart';
import 'package:mae_assignment/sister_files/widgets/reusable_widgets.dart';


class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final UserController _controller = UserController();
  final FeedController _feedController = FeedController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
        actions: [
          NotificationIcon(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _controller.getUserProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Error: Profile not found"));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromARGB(255, 216, 166, 176),
                    backgroundImage: (userData["profileIcon"] != null &&
                            userData["profileIcon"] != "")
                        ? NetworkImage(userData["profileIcon"])
                        : null,
                    child: (userData["profileIcon"] == null ||
                            userData["profileIcon"] == "")
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Username
                  Text(
                    userData["username"] ?? "No Name",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),

                  // Buttons
                  CustomButton(
                    text: "Edit Profile",
                    onPressed: () {
                      Navigator.pushNamed(context, "/editProfile");
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: "Logout",
                    backgroundColor: const Color.fromARGB(255, 121, 78, 89),
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                  ),
                  const SizedBox(height: 30),

                  // Divider
                  const Divider(),
                  const SizedBox(height: 10),

                  // Posts Section
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        _feedController.getUserPostsStream(currentUser!.uid),
                    builder: (context, postSnapshot) {
                      if (postSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!postSnapshot.hasData ||
                          postSnapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("You haven’t posted anything yet."),
                        );
                      }

                      final posts = postSnapshot.data!.docs;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, 
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];

                          return OwnPostCard(
                            imageUrl: post['imageUrl'],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OwnPostDetailScreen(
                                    postId: post.id,
                                    imageUrl: post['imageUrl'],
                                    description: post['description'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
