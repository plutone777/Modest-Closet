import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_detail_dialog.dart'; // Import your post detail dialog

class ReviewAccountsPage extends StatefulWidget {
  const ReviewAccountsPage({super.key});

  static const Color cardColor = Color(0xFFF9E7E9);
  static const Color iconBg = Color(0xFFD3A3AD);
  static const Color cardTextColor = Color(0xFF412934);

  @override
  State<ReviewAccountsPage> createState() => _ReviewAccountsPageState();
}

class _ReviewAccountsPageState extends State<ReviewAccountsPage> {
  Map<String, dynamic>? selectedAccountDetail;

  void _handleAccountTap(Map<String, dynamic> accountDetail) {
    setState(() {
      selectedAccountDetail = accountDetail;
    });
  }

  void _closeDetail() {
    setState(() {
      selectedAccountDetail = null;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchUserPosts(
      String userId, List<dynamic> postIds) async {
    List<Map<String, dynamic>> posts = [];

    for (final postId in postIds) {
      if (postId is String) {
        final docInPosts =
            await FirebaseFirestore.instance.collection('Posts').doc(postId).get();
        if (docInPosts.exists) {
          posts.add({'id': docInPosts.id, 'data': docInPosts.data()});
          continue;
        }

        final docInLowercasePosts =
            await FirebaseFirestore.instance.collection('posts').doc(postId).get();
        if (docInLowercasePosts.exists) {
          posts.add({'id': docInLowercasePosts.id, 'data': docInLowercasePosts.data()});
        }
      }
    }
    return posts;
  }

  void _openPostDetailDialog(Map<String, dynamic> postData) {
    showDialog(
      context: context,
      builder: (_) => PostDetailDialog(
        username: selectedAccountDetail?['username'] ?? 'Unknown',
        postId: postData['id'],
        imageUrl: postData['data']?['postImageUrl'] ?? '',
        description: postData['data']?['description'] ?? '',
        userId: selectedAccountDetail?['userId'] ?? '',
        isStylist: (selectedAccountDetail?['role'] == 'stylist'),
      ),
    );
  }

  Future<void> _banUser(String userId) async {
    final batch = FirebaseFirestore.instance.batch();

    // حذف المستخدم من Users
    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    batch.delete(userDocRef);

    // حذف من Review_accounts
    final reviewDocRef = FirebaseFirestore.instance.collection('Review_accounts').doc(userId);
    batch.delete(reviewDocRef);

    await batch.commit();
  }

  Future<void> _markUserSafe(String userId) async {
    // حذف فقط من Review_accounts
    await FirebaseFirestore.instance.collection('Review_accounts').doc(userId).delete();
  }

  Future<void> _showBanSafeDialog(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("User Action"),
        content: const Text("Choose an action for this user."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _markUserSafe(userId);
              Navigator.of(ctx).pop(true);
              _closeDetail();
            },
            style: TextButton.styleFrom(
              backgroundColor: ReviewAccountsPage.iconBg,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Safe"),
          ),
          TextButton(
            onPressed: () async {
              final banConfirmed = await showDialog<bool>(
                context: ctx,
                builder: (ctx2) => AlertDialog(
                  title: const Text("Confirm Ban"),
                  content: const Text(
                      "Are you sure you want to ban this user? This will delete the user completely."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx2).pop(false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx2).pop(true),
                      style: TextButton.styleFrom(
                        backgroundColor: ReviewAccountsPage.cardTextColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Ban"),
                    ),
                  ],
                ),
              );
              if (banConfirmed == true) {
                await _banUser(userId);
                Navigator.of(ctx).pop(true);
                _closeDetail();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: ReviewAccountsPage.cardTextColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Ban"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Do nothing extra because dialog handlers already close detail and act
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Review_accounts')
              .orderBy('reviewedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child:
                      CircularProgressIndicator(color: ReviewAccountsPage.cardTextColor));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No accounts under review.",
                  style: TextStyle(
                    color: ReviewAccountsPage.cardTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }

            final accounts = snapshot.data!.docs;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 4,
              ),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index].data() as Map<String, dynamic>;
                return _AccountCard(
                  accountDetail: account,
                  onTap: () => _handleAccountTap(account),
                  onLongPress: () => _showBanSafeDialog(account['userId'] as String),
                );
              },
            );
          },
        ),
        if (selectedAccountDetail != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: ReviewAccountDetail(
                  accountDetail: selectedAccountDetail!,
                  onClose: _closeDetail,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Map<String, dynamic> accountDetail;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _AccountCard({
    required this.accountDetail,
    required this.onTap,
    required this.onLongPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileIcon = accountDetail['profileIcon'] as String? ?? '';
    final username = accountDetail['username'] as String? ?? 'Unknown';
    final role = accountDetail['role'] as String? ?? '';
    final profession = accountDetail['profession'] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: ReviewAccountsPage.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: ReviewAccountsPage.iconBg,
              backgroundImage:
                  profileIcon.isNotEmpty ? NetworkImage(profileIcon) : null,
              child: profileIcon.isEmpty
                  ? const Icon(Icons.person,
                      size: 40, color: ReviewAccountsPage.cardTextColor)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: ReviewAccountsPage.cardTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (role.isNotEmpty)
              Text(
                role,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            if (profession.isNotEmpty)
              Text(
                profession,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class ReviewAccountDetail extends StatefulWidget {
  final Map<String, dynamic> accountDetail;
  final VoidCallback onClose;

  const ReviewAccountDetail({
    required this.accountDetail,
    required this.onClose,
    Key? key,
  }) : super(key: key);

  @override
  State<ReviewAccountDetail> createState() => _ReviewAccountDetailState();
}

class _ReviewAccountDetailState extends State<ReviewAccountDetail> {
  String? selectedPostId;
  Map<String, dynamic>? selectedPostDetail;

  Future<List<Map<String, dynamic>>> _fetchUserPosts(
      String userId, List<dynamic> postIds) async {
    List<Map<String, dynamic>> posts = [];

    for (final postId in postIds) {
      if (postId is String) {
        // Try fetching from both collections: 'Posts' and 'posts'
        final docInPosts =
            await FirebaseFirestore.instance.collection('Posts').doc(postId).get();
        if (docInPosts.exists) {
          posts.add({'id': docInPosts.id, 'data': docInPosts.data()});
          continue; // next postId if found here
        }

        final docInLowercasePosts =
            await FirebaseFirestore.instance.collection('posts').doc(postId).get();
        if (docInLowercasePosts.exists) {
          posts.add({'id': docInLowercasePosts.id, 'data': docInLowercasePosts.data()});
        }
      }
    }
    return posts;
  }

  void _openPostDetailDialog(Map<String, dynamic> postData) {
    showDialog(
      context: context,
      builder: (_) => PostDetailDialog(
        username: widget.accountDetail['username'] ?? 'Unknown',
        postId: postData['id'],
        imageUrl: postData['data']?['postImageUrl'] ?? '',
        description: postData['data']?['description'] ?? '',
        userId: widget.accountDetail['userId'] ?? '',
        isStylist: (widget.accountDetail['role'] == 'stylist'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.accountDetail;
    final profileIcon = account['profileIcon'] as String? ?? '';
    final username = account['username'] as String? ?? 'Unknown';
    final role = account['role'] as String? ?? '';
    final profession = account['profession'] as String? ?? '';
    final postsIds = account['postsIds'] as List<dynamic>? ?? [];

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 360,
        height: 500,
        child: Column(
          children: [
            // Header with close button and profile info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: ReviewAccountsPage.iconBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: ReviewAccountsPage.cardColor,
                    backgroundImage:
                        profileIcon.isNotEmpty ? NetworkImage(profileIcon) : null,
                    child: profileIcon.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ReviewAccountsPage.cardTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: ReviewAccountsPage.cardTextColor),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchUserPosts(account['userId'] ?? '', postsIds),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: ReviewAccountsPage.cardTextColor));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("No posts found.",
                            style: TextStyle(color: ReviewAccountsPage.cardTextColor)));
                  }
                  final posts = snapshot.data!;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final postData = post['data'] as Map<String, dynamic>? ?? {};
                      final imageUrl = postData['postImageUrl'] ?? '';
                      final description = postData['description'] ?? '';

                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(imageUrl,
                                      width: 60, height: 60, fit: BoxFit.cover),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: ReviewAccountsPage.iconBg.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image,
                                      size: 40, color: ReviewAccountsPage.iconBg),
                                ),
                          title: Text(
                            description.isNotEmpty ? description : '(No description)',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _openPostDetailDialog(post),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
