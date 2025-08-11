import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportedPostsGrid extends StatefulWidget {
  final bool isVisible;
  const ReportedPostsGrid({super.key, required this.isVisible});

  static const Color cardColor = Color(0xFFF9E7E9);
  static const Color iconBg = Color(0xFFD3A3AD);
  static const Color cardTextColor = Color(0xFF412934);

  @override
  State<ReportedPostsGrid> createState() => _ReportedPostsGridState();
}

class _ReportedPostsGridState extends State<ReportedPostsGrid> {
  int? selectedIndex;
  Map<String, dynamic>? selectedPostDetail;

  void _handleCardTap(int idx, Map<String, dynamic> postDetail) {
    setState(() {
      if (selectedIndex == idx) {
        selectedIndex = null;
        selectedPostDetail = null;
      } else {
        selectedIndex = idx;
        selectedPostDetail = postDetail;
      }
    });
  }

  Future<void> _removeFromReportedPosts(String postId, String userId) async {
    final snap = await FirebaseFirestore.instance
        .collection('ReportedPosts')
        .where('postId', isEqualTo: postId)
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _deletePostEverywhere(String postId, String userId) async {
    final userSnap = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final role = userSnap.data()?['role'] ?? "sister";

    final postsCollection = (role == "stylist") ? "posts" : "Posts";

    await FirebaseFirestore.instance.collection(postsCollection).doc(postId).delete().catchError((_) {});
    await _removeFromReportedPosts(postId, userId);
  }

  Future<void> _sendUserForReviewAndDeletePost(String userId, String postId) async {
    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (!userDoc.exists) return;

    final userData = userDoc.data()!;
    final role = userData['role'] ?? 'sister';

    List<String> postCollections = [];
    if (role == 'stylist') {
      postCollections.add('posts');
    } else {
      postCollections.add('Posts');
    }
    if (!postCollections.contains('posts')) postCollections.add('posts');
    if (!postCollections.contains('Posts')) postCollections.add('Posts');

    List<String> allPostIds = [];
    for (String col in postCollections) {
      final querySnap = await FirebaseFirestore.instance
          .collection(col)
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in querySnap.docs) {
        allPostIds.add(doc.id);
      }
    }

    final reviewData = {
      'userId': userId,
      'username': userData['username'] ?? '',
      'profileIcon': userData['profileIcon'] ?? '',
      'role': role,
      'profession': userData['profession'] ?? '',
      'postsIds': allPostIds,
      'postsCount': allPostIds.length,
      'reviewedAt': FieldValue.serverTimestamp(),
    };

    final existingSnap = await FirebaseFirestore.instance
        .collection('Review_accounts')
        .where('userId', isEqualTo: userId)
        .get();

    if (existingSnap.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('Review_accounts').add(reviewData);
    } else {
      await existingSnap.docs.first.reference.update(reviewData);
    }

    await _removeFromReportedPosts(postId, userId);

    if (selectedPostDetail != null && selectedPostDetail!['postId'] == postId) {
      setState(() {
        selectedIndex = null;
        selectedPostDetail = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        ignoring: !widget.isVisible,
        child: Column(
          children: [
            SizedBox(
              height: 185,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ReportedPosts')
                    .orderBy('reportedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: ReportedPostsGrid.cardTextColor));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No reported posts.",
                          style: TextStyle(
                              color: ReportedPostsGrid.cardTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    );
                  }

                  final reports = snapshot.data!.docs;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index].data() as Map<String, dynamic>;
                      final postId = report['postId'];
                      final userId = report['userId'];
                      final reportedAt = report['reportedAt'];
                      final reason = report['reason'];
                      return _ReportedPostCard(
                        postId: postId,
                        userId: userId,
                        reportedAt: reportedAt,
                        reason: reason,
                        onTap: (detail) => _handleCardTap(index, detail),
                        isSelected: selectedIndex == index,
                        autoRemove: null,
                        onReview: () {
                          _sendUserForReviewAndDeletePost(userId, postId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User sent for review, post removed')),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            if (selectedIndex != null && selectedPostDetail != null)
              _DetailBar(
                detail: selectedPostDetail!,
                onClose: () => setState(() {
                  selectedIndex = null;
                  selectedPostDetail = null;
                }),
                onIgnore: () async {
                  final d = selectedPostDetail!;
                  await _removeFromReportedPosts(d['postId'], d['userId']);
                  setState(() {
                    selectedIndex = null;
                    selectedPostDetail = null;
                  });
                },
                onDelete: () async {
                  final d = selectedPostDetail!;
                  await _deletePostEverywhere(d['postId'], d['userId']);
                  setState(() {
                    selectedIndex = null;
                    selectedPostDetail = null;
                  });
                },
                onReview: () {
                  final d = selectedPostDetail!;
                  _sendUserForReviewAndDeletePost(d['userId'], d['postId']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User sent for review, post removed')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportedPostCard extends StatelessWidget {
  final String postId;
  final String userId;
  final dynamic reportedAt;
  final dynamic reason;
  final void Function(Map<String, dynamic> detail) onTap;
  final bool isSelected;
  final Future<void> Function(String, String, String?, String?)? autoRemove;
  final VoidCallback? onReview;

  static const Color cardColor = Color(0xFFF9E7E9);
  static const Color iconBg = Color(0xFFD3A3AD);
  static const Color cardTextColor = Color(0xFF412934);

  const _ReportedPostCard({
    required this.postId,
    required this.userId,
    this.reportedAt,
    required this.reason,
    required this.onTap,
    required this.isSelected,
    this.autoRemove,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
      builder: (context, userSnap) {
        String role = "sister";
        if (userSnap.hasData && userSnap.data != null && userSnap.data!.exists) {
          role = userSnap.data!['role'] ?? "sister";
        }
        String postsCollection = (role == "stylist") ? "posts" : "Posts";

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection(postsCollection).doc(postId).get(),
          builder: (context, postSnap) {
            final userData = (userSnap.hasData && userSnap.data != null && userSnap.data!.exists)
                ? userSnap.data!.data() as Map<String, dynamic>
                : {};
            final postData = (postSnap.hasData && postSnap.data != null && postSnap.data!.exists)
                ? postSnap.data!.data() as Map<String, dynamic>
                : {};

            String? imageUrl;

            if (role == "stylist" &&
                postData.containsKey('postImageUrl1') &&
                postData['postImageUrl1'] != null &&
                (postData['postImageUrl1'] as String).isNotEmpty) {
              imageUrl = postData['postImageUrl1'] as String;
            } else if (postData.containsKey('imageUrl') &&
                postData['imageUrl'] != null &&
                (postData['imageUrl'] as String).isNotEmpty) {
              imageUrl = postData['imageUrl'] as String;
            } else {
              imageUrl = null;
            }

            String userName = userData['username'] ?? "Unknown";
            String? description = postData['description'];
            DateTime? created;
            if (reportedAt is Timestamp) {
              created = reportedAt.toDate();
            } else if (reportedAt is DateTime) {
              created = reportedAt;
            }
            String dateText = created != null
                ? "${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')}"
                : "";

            return _buildCard(
              context,
              imageUrl,
              userName,
              description,
              reason,
              dateText,
              () => onTap({
                'imageUrl': imageUrl,
                'username': userName,
                'description': description,
                'reason': reason,
                'postId': postId,
                'userId': userId,
                'date': dateText,
              }),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    String? imageUrl,
    String? userName,
    String? description,
    dynamic reason,
    String? date, [
    VoidCallback? onTap,
  ]) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 10, right: 10, bottom: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 65,
                          height: 65,
                          color: iconBg.withOpacity(0.16),
                          child: const Icon(Icons.image, color: iconBg, size: 32),
                        ),
                      )
                    : Container(
                        width: 65,
                        height: 65,
                        color: iconBg.withOpacity(0.16),
                        child: const Icon(Icons.image, color: iconBg, size: 32),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                userName ?? "Unknown",
                style: const TextStyle(
                  color: cardTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            if (date != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  date,
                  style: const TextStyle(
                      color: cardTextColor, fontSize: 12, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailBar extends StatelessWidget {
  final Map<String, dynamic> detail;
  final VoidCallback onClose;
  final VoidCallback onIgnore;
  final VoidCallback onDelete;
  final VoidCallback? onReview;

  static const Color cardColor = Color(0xFFF9E7E9);
  static const Color textColor = Color(0xFF412934);
  static const Color iconBg = Color(0xFFD3A3AD);
  static const Color action1 = Color(0xFFD3A3AD);
  static const Color action2 = Color(0xFF56313E);
  static const Color action3 = Color(0xFF854F5E);

  const _DetailBar({
    required this.detail,
    required this.onClose,
    required this.onIgnore,
    required this.onDelete,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final reasons = detail['reason'];
    final bool showReasonButton = reasons is List && reasons.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconBg, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail['imageUrl'] != null && (detail['imageUrl'] as String).isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                detail['imageUrl'],
                width: 84,
                height: 84,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.image, color: iconBg, size: 42),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        detail['username'] ?? "",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: textColor),
                      onPressed: onClose,
                    )
                  ],
                ),
                if (showReasonButton)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, top: 2),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconBg,
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      icon: const Icon(Icons.error_outline, size: 17),
                      label: Text("Show Reasons (${(reasons).length})"),
                      onPressed: () {
                        final uniqueReasons = <String, int>{};
                        for (final r in reasons) {
                          if (r is String && r.trim().isNotEmpty) {
                            uniqueReasons[r] = (uniqueReasons[r] ?? 0) + 1;
                          }
                        }
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              backgroundColor: cardColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28)),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Report Reasons (${uniqueReasons.length})",
                                            style: const TextStyle(
                                              color: textColor,
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: 320,
                                      height: uniqueReasons.length > 4 ? 200 : null,
                                      child: Scrollbar(
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: uniqueReasons.entries
                                              .map((e) => Padding(
                                                    padding: const EdgeInsets.only(bottom: 12.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            e.key,
                                                            style: const TextStyle(
                                                              color: textColor,
                                                              fontSize: 17,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          "x${e.value}",
                                                          style: const TextStyle(
                                                              color: textColor,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: iconBg,
                                          foregroundColor: textColor,
                                          minimumSize: const Size(110, 36),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18)),
                                          textStyle: const TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold),
                                          elevation: 0,
                                        ),
                                        child: const Text("OK"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                if (detail['description'] != null && (detail['description'] as String).isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 72, minHeight: 24),
                    margin: const EdgeInsets.only(top: 2.0, bottom: 8),
                    child: SingleChildScrollView(
                      child: Text(
                        detail['description'],
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onIgnore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: action1,
                          foregroundColor: textColor,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text("Ignore", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: action2,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: action3,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text("Review", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
