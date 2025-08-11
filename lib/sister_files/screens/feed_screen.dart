import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mae_assignment/sister_files/controllers/feed_controller.dart';
import 'package:mae_assignment/sister_files/screens/notifications_screen.dart';
import 'package:mae_assignment/sister_files/screens/posts/upload_post_screen.dart';
import 'package:mae_assignment/sister_files/widgets/postlist.dart';
import 'package:mae_assignment/sister_files/widgets/reusable_widgets.dart';

class FeedScreen extends StatelessWidget {
  FeedScreen({super.key});

  final FeedController _feedController = FeedController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Feed"),
          backgroundColor: const Color.fromARGB(255, 216, 166, 176),
          foregroundColor: Colors.white,
          actions: [
            NotificationIcon(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Community"),
              Tab(text: "Stylists"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Community Tab
            PostList(
              stream: _feedController.getPostsStream(userId),
              emptyMessage: "No community posts yet.",
              emptyIcon: Icons.people_alt_outlined,
            ),

            // Stylist Tab
            PostList(
              stream: _feedController.getStylistPostsStream(),
              emptyMessage: "No stylist posts yet.",
              emptyIcon: Icons.brush,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 216, 166, 176),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadPostScreen(userId: userId),
              ),
            );
          },
        ),
      ),
    );
  }
}
