// lib/features/stylist/screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mae_assignment/stylist_files/theme/app_theme.dart';
import 'package:mae_assignment/stylist_files/models/stylist_models.dart';
import 'package:mae_assignment/stylist_files/screens/post_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late Future<Map<String, dynamic>> _profileDataFuture;

  bool _isFollowing = false;
  bool _isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData();
    if (widget.userId != currentUserId && currentUserId != null) {
      _incrementProfileView();
      _checkIfFollowing();
    }
  }

  Future<Map<String, dynamic>> _fetchProfileData() async {
    final profileDocFuture =
        FirebaseFirestore.instance.collection('Users').doc(widget.userId).get();
    final postsQueryFuture =
        FirebaseFirestore.instance
            .collection('posts')
            .where('authorId', isEqualTo: widget.userId)
            .orderBy('timestamp', descending: true)
            .get();
    final results = await Future.wait([profileDocFuture, postsQueryFuture]);
    if (!(results[0] as DocumentSnapshot).exists)
      throw Exception('User profile not found.');
    final stylistProfile = StylistProfile.fromFirestore(
      results[0] as DocumentSnapshot,
    );
    final posts =
        (results[1] as QuerySnapshot).docs
            .map((doc) => Post.fromFirestore(doc))
            .toList();
    return {'profile': stylistProfile, 'posts': posts};
  }

  Future<void> _checkIfFollowing() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUserId)
            .collection('following')
            .doc(widget.userId)
            .get();
    if (mounted) setState(() => _isFollowing = doc.exists);
  }

  // --- ALL DATABASE LOGIC IS NOW CORRECTED TO BE PERSONALIZED ---

  Future<void> _incrementProfileView() async {
    final statsRef = FirebaseFirestore.instance
        .collection('stylist_stats')
        .doc(widget.userId);
    await statsRef.set({
      'profileViews': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<void> _toggleFollow() async {
    if (currentUserId == null || currentUserId == widget.userId) return;
    setState(() => _isLoadingFollow = true);

    final currentUserRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId);
    final otherUserRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId);
    final otherUserStatsRef = FirebaseFirestore.instance
        .collection('stylist_stats')
        .doc(widget.userId);
    final batch = FirebaseFirestore.instance.batch();

    if (_isFollowing) {
      batch.delete(currentUserRef.collection('following').doc(widget.userId));
      batch.delete(otherUserRef.collection('followers').doc(currentUserId));
      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(-1),
      });
      batch.update(otherUserRef, {'followersCount': FieldValue.increment(-1)});
      batch.update(otherUserStatsRef, {
        'newFollowers': FieldValue.increment(-1),
      });
    } else {
      batch.set(currentUserRef.collection('following').doc(widget.userId), {
        'timestamp': FieldValue.serverTimestamp(),
      });
      batch.set(otherUserRef.collection('followers').doc(currentUserId), {
        'timestamp': FieldValue.serverTimestamp(),
      });
      batch.update(currentUserRef, {'followingCount': FieldValue.increment(1)});
      batch.update(otherUserRef, {'followersCount': FieldValue.increment(1)});
      batch.update(otherUserStatsRef, {
        'newFollowers': FieldValue.increment(1),
      });
      batch.set(otherUserRef.collection('notifications').doc(), {
        'title': 'New Follower',
        'body': 'You have a new follower!',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'senderId': currentUserId,
      });
    }

    await batch.commit();
    if (mounted)
      setState(() {
        _isFollowing = !_isFollowing;
        _isLoadingFollow = false;
        _profileDataFuture = _fetchProfileData();
      });
  }

  Future<void> _sendClientRequest() async {
    if (currentUserId == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final senderDoc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUserId)
              .get();
      final senderUsername = senderDoc.data()?['username'] ?? 'A Client';
      final senderImageUrl = senderDoc.data()?['profileImageUrl'] ?? '';

      await FirebaseFirestore.instance.collection('client_requests').add({
        'fromUserId': currentUserId,
        'fromUsername': senderUsername,
        'fromUserImageUrl': senderImageUrl,
        'toUserId': widget.userId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      final statsRef = FirebaseFirestore.instance
          .collection('stylist_stats')
          .doc(widget.userId);
      await statsRef.set({
        'newClientRequests': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('notifications')
          .add({
            'title': 'New Client Request',
            'body': '$senderUsername wants to connect with you!',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'senderId': currentUserId,
          });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Client request sent!')));
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send request: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId == currentUserId ? "My Profile" : "Profile"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData)
            return const Center(child: Text("User not found."));

          final StylistProfile stylist = snapshot.data!['profile'];
          final List<Post> posts = snapshot.data!['posts'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(stylist, posts.length),
                const SizedBox(height: 24),
                if (currentUserId != widget.userId) _buildActionButtons(),
                const SizedBox(height: 24),
                const Divider(),
                _buildPostsGrid(posts),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI WIDGETS (UNCHANGED) ---
  Widget _buildProfileHeader(StylistProfile stylist, int postCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  stylist.profileImageUrl.isNotEmpty
                      ? NetworkImage(stylist.profileImageUrl)
                      : null,
              child:
                  stylist.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
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
            onPressed: _isLoadingFollow ? null : _toggleFollow,
            child: Text(_isFollowing ? 'Following' : 'Follow'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isFollowing ? Colors.grey.shade600 : Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _sendClientRequest,
            child: const Text('Send Request'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsGrid(List<Post> posts) {
    if (posts.isEmpty)
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text(
            "This user hasn't posted anything yet.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
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
            child: Image.network(posts[index].postImageUrl, fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  Column _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
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
}
