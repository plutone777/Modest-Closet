import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportedAccountsPage extends StatefulWidget {
  final bool isVisible;
  const ReportedAccountsPage({super.key, this.isVisible = true});

  static const Color cardColor = Color(0xFFF9E7E9);
  static const Color iconBg = Color(0xFFD3A3AD);
  static const Color cardTextColor = Color(0xFF412934);

  @override
  State<ReportedAccountsPage> createState() => _ReportedAccountsPageState();
}

class _ReportedAccountsPageState extends State<ReportedAccountsPage> {
  int? selectedIndex;
  Map<String, dynamic>? selectedAccountDetail;

  void _handleCardTap(int idx, Map<String, dynamic> accountDetail) {
    setState(() {
      if (selectedIndex == idx) {
        selectedIndex = null;
        selectedAccountDetail = null;
      } else {
        selectedIndex = idx;
        selectedAccountDetail = accountDetail;
      }
    });
  }

  Future<void> _removeFromReportedAccounts(String? userId) async {
    if (userId == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('Reportedaccounts')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _deleteUserEverywhere(String? userId) async {
    if (userId == null) return;
    // Delete user document in Users collection
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .delete()
        .catchError((_) {});
    // Remove user from reported accounts
    await _removeFromReportedAccounts(userId);
  }

  /// The new method: send user info + all post IDs (from "posts" and "Posts") + total count to Review_accounts collection
  Future<void> _sendUserForReview(String userId) async {
    if (userId.isEmpty) return;

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
  }

  @override
  Widget build(BuildContext context) {
    const double accountsAreaHeight = 170;

    return AnimatedOpacity(
      opacity: widget.isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        ignoring: !widget.isVisible,
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "Reported Accounts",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: ReportedAccountsPage.cardTextColor,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: accountsAreaHeight,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Reportedaccounts')
                    .orderBy('reportedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: ReportedAccountsPage.cardTextColor),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No reported accounts.",
                        style: TextStyle(
                          color: ReportedAccountsPage.cardTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  final reports = snapshot.data!.docs;

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index].data() as Map<String, dynamic>? ?? {};
                      final userId = report['userId']?.toString() ?? '';
                      final reason = report['reason'];
                      final reportedAt = report['reportedAt'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: _ReportedAccountCard(
                          userId: userId,
                          reportedAt: reportedAt,
                          reason: reason,
                          isSelected: selectedIndex == index,
                          onTap: (detail) => _handleCardTap(index, detail),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (selectedAccountDetail != null)
              _DetailBar(
                detail: selectedAccountDetail!,
                onClose: () => setState(() {
                  selectedIndex = null;
                  selectedAccountDetail = null;
                }),
                onIgnore: () async {
                  final d = selectedAccountDetail!;
                  await _removeFromReportedAccounts(d['userId'] as String?);
                  setState(() {
                    selectedIndex = null;
                    selectedAccountDetail = null;
                  });
                },
                onDelete: () async {
                  final d = selectedAccountDetail!;
                  await _deleteUserEverywhere(d['userId'] as String?);
                  setState(() {
                    selectedIndex = null;
                    selectedAccountDetail = null;
                  });
                },
                onReview: () async {
                  final d = selectedAccountDetail!;
                  final userId = d['userId'] as String?;
                  if (userId != null && userId.isNotEmpty) {
                    await _sendUserForReview(userId);
                    await _removeFromReportedAccounts(userId);
                    // Optionally close the detail bar
                    setState(() {
                      selectedIndex = null;
                      selectedAccountDetail = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User sent for review, removed from reported accounts')),
                    );
                  }
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ReportedAccountCard extends StatelessWidget {
  final String userId;
  final dynamic reportedAt;
  final dynamic reason;
  final void Function(Map<String, dynamic> detail) onTap;
  final bool isSelected;

  static const Color cardColor = Color(0xFFF9E7E9);
  static const Color iconBg = Color(0xFFD3A3AD);
  static const Color cardTextColor = Color(0xFF412934);

  const _ReportedAccountCard({
    required this.userId,
    this.reportedAt,
    required this.reason,
    required this.onTap,
    required this.isSelected,
    super.key,
  });

  Future<Map<String, dynamic>?> _fetchUserData() async {
    if (userId.isEmpty) return null;

    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (userDoc.exists) return userDoc.data();

    // If you have stylist or sister collections, check here similarly:
    // For example: stylist collection
    final stylistDoc = await FirebaseFirestore.instance.collection('stylists').doc(userId).get();
    if (stylistDoc.exists) return stylistDoc.data();

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text("User not found"),
          );
        }

        final userData = snapshot.data!;
        final userPic = userData['profileIcon'] ?? "";
        String username = userData['username'] ?? "Unknown";
        final role = userData['role'];
        final email = userData['email'] ?? "";
        final phone = userData['phone'] ?? "";
        final profession = userData['profession'] ?? "";
        final status = userData['status'] ?? "";
        final createdAtRaw = userData['createdAt'];
        DateTime? createdAt;
        if (createdAtRaw is Timestamp) {
          createdAt = createdAtRaw.toDate();
        } else if (createdAtRaw is DateTime) {
          createdAt = createdAtRaw;
        }
        String createdAtText = createdAt != null
            ? "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}"
            : "";

        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: isSelected ? Border.all(color: cardTextColor, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            onTap: () => onTap({
              'profileIcon': userPic,
              'username': username,
              'role': role,
              'email': email,
              'phone': phone,
              'profession': profession,
              'status': status,
              'userId': userId,
              'createdAt': createdAtText,
              'reason': reason,
            }),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: userPic.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(userPic),
                    radius: 23,
                    backgroundColor: Colors.transparent,
                  )
                : const CircleAvatar(
                    backgroundColor: iconBg,
                    radius: 23,
                    child: Icon(Icons.person, color: cardTextColor, size: 25),
                  ),
            title: Text(
              username,
              style: const TextStyle(
                color: cardTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (role != null)
                  Text(
                    "Role: $role",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (email.isNotEmpty)
                  Text(
                    "Email: $email",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (phone.isNotEmpty)
                  Text(
                    "Phone: $phone",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (profession.isNotEmpty)
                  Text(
                    "Profession: $profession",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (createdAtText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1.5),
                    child: Text(
                      "Created at: $createdAtText",
                      style: const TextStyle(color: Color(0xFF85565E), fontSize: 12),
                    ),
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: cardTextColor),
          ),
        );
      },
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
    final dynamic reasonsRaw = detail['reason'];
    final List<String> reasons = [];

    if (reasonsRaw is List) {
      for (var item in reasonsRaw) {
        if (item is String && item.trim().isNotEmpty) {
          reasons.add(item);
        }
      }
    } else if (reasonsRaw is String && reasonsRaw.trim().isNotEmpty) {
      reasons.add(reasonsRaw);
    }

    final bool showReasonButton = reasons.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
          if (detail['profileIcon'] != null && (detail['profileIcon'] as String).isNotEmpty)
            CircleAvatar(
              backgroundImage: NetworkImage(detail['profileIcon']),
              radius: 32,
              backgroundColor: Colors.transparent,
            )
          else
            const CircleAvatar(
              backgroundColor: iconBg,
              radius: 32,
              child: Icon(Icons.person, color: textColor, size: 33),
            ),
          const SizedBox(width: 10),
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
                          fontSize: 18,
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
                      label: Text("Show Reasons (${reasons.length})"),
                      onPressed: () {
                        final uniqueReasons = <String, int>{};
                        for (final r in reasons) {
                          uniqueReasons[r] = (uniqueReasons[r] ?? 0) + 1;
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
                                              fontSize: 21,
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
                                                              fontSize: 16,
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
                if (detail['email'] != null && (detail['email'] as String).isNotEmpty)
                  Text(
                    "Email: ${detail['email']}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                if (detail['phone'] != null && (detail['phone'] as String).isNotEmpty)
                  Text(
                    "Phone: ${detail['phone']}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                if (detail['role'] != null && detail['role'].toString().isNotEmpty && detail['role'].toString() != 'sister')
                  Text(
                    "Role: ${detail['role']}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                if (detail['profession'] != null && detail['profession'].toString().isNotEmpty)
                  Text(
                    "Profession: ${detail['profession']}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                if (detail['status'] != null && (detail['status'] as String).isNotEmpty)
                  Text(
                    "Status: ${detail['status']}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                if (detail['createdAt'] != null && (detail['createdAt'] as String).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1.5),
                    child: Text(
                      "Created at: ${detail['createdAt']}",
                      style: const TextStyle(color: Color(0xFF85565E), fontSize: 12),
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
