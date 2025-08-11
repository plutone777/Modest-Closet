// lib/features/stylist/screens/stylist_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mae_assignment/stylist_files/models/stylist_models.dart';
import 'package:mae_assignment/stylist_files/screens/post_detail_screen.dart'; // <-- ADD THIS LINE
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class StylistProfileScreen extends StatefulWidget {
  const StylistProfileScreen({super.key});

  @override
  State<StylistProfileScreen> createState() => _StylistProfileScreenState();
}

class _StylistProfileScreenState extends State<StylistProfileScreen> {
  // Get the current user from Firebase Auth
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // The Future will hold the combined profile and post data
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    // Only attempt to fetch data if a user is logged in
    if (currentUser != null) {
      _profileDataFuture = _fetchProfileData();
    }
  }

  // --- DATA FETCHING METHODS ---
  Future<Map<String, dynamic>> _fetchProfileData() async {
    // This check is crucial.
    if (currentUser == null) throw Exception('No user is currently logged in.');

    // Fetch the user's profile document from the 'Users' collection
    final profileDocFuture =
        FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.uid)
            .get();

    // Fetch the posts created by this user from the 'posts' collection
    final postsQueryFuture =
        FirebaseFirestore.instance
            .collection('posts')
            .where(
              'authorId',
              isEqualTo: currentUser!.uid,
            ) // Filter by the user's ID
            .orderBy('timestamp', descending: true)
            .get();

    // Wait for both database requests to complete at the same time for efficiency
    final results = await Future.wait([profileDocFuture, postsQueryFuture]);

    final profileDoc = results[0] as DocumentSnapshot;
    final postsQuery = results[1] as QuerySnapshot;

    if (!profileDoc.exists) {
      throw Exception('User profile document not found in Firestore.');
    }

    // Convert the raw data into our custom model objects
    final stylistProfile = StylistProfile.fromFirestore(profileDoc);
    final posts =
        postsQuery.docs.map((doc) => Post.fromFirestore(doc)).toList();

    // Return all the fetched data in a structured map
    return {'profile': stylistProfile, 'posts': posts};
  }

  // This function is called by the pull-to-refresh action
  Future<void> _refreshProfile() async {
    if (currentUser != null) {
      setState(() {
        _profileDataFuture = _fetchProfileData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no user is logged in, show a helpful message and a button to go to the login screen
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Please log in to view your profile.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    ),
                child: const Text("Go to Login"),
              ),
            ],
          ),
        ),
      );
    }

    // If a user is logged in, build the profile screen using the FutureBuilder
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          if (!snapshot.hasData)
            return const Center(child: Text("No data found."));

          final StylistProfile stylist = snapshot.data!['profile'];
          final List<Post> posts = snapshot.data!['posts'];

          return RefreshIndicator(
            onRefresh: _refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(stylist, posts.length),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  const Divider(),
                  _buildPostsGrid(posts),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- HELPER WIDGETS ---
  // These build the different parts of the UI using the fetched data.

  Widget _buildProfileHeader(StylistProfile stylist, int postCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(stylist.profileImageUrl),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatColumn(postCount.toString(), 'Posts'),
                  _buildStatColumn(
                    stylist.followersCount.toString(),
                    'Followers',
                  ),
                  _buildStatColumn(
                    stylist.followingCount.toString(),
                    'Following',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          stylist.username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(stylist.profession, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                ),
            child: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
          child: const Icon(Icons.settings_outlined),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Colors.grey.shade400),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsGrid(List<Post> posts) {
    if (posts.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text(
            "You haven't shared any posts yet.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: posts[index]),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.network(
              posts[index].postImageUrl,
              fit: BoxFit.cover,
              loadingBuilder:
                  (context, child, progress) =>
                      progress == null
                          ? child
                          : Container(color: Colors.grey[200]),
              errorBuilder:
                  (context, error, stack) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
            ),
          ),
        );
      },
    );
  }

  Column _buildStatColumn(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
    ],
  );
}
