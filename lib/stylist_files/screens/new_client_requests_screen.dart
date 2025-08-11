// lib/features/stylist/screens/new_client_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewClientRequestsScreen extends StatefulWidget {
  const NewClientRequestsScreen({super.key});

  @override
  State<NewClientRequestsScreen> createState() =>
      _NewClientRequestsScreenState();
}

class _NewClientRequestsScreenState extends State<NewClientRequestsScreen> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _handleRequest(
    Map<String, dynamic> requestData,
    String requestId,
    bool isAccepted,
  ) async {
    if (currentUserId == null) return;

    final fromUserId = requestData['fromUserId'];
    final requestRef = FirebaseFirestore.instance
        .collection('client_requests')
        .doc(requestId);
    final stylistRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId);
    final clientRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(fromUserId);

    final batch = FirebaseFirestore.instance.batch();

    if (isAccepted) {
      batch.set(stylistRef.collection('clients').doc(fromUserId), {
        'username': requestData['fromUsername'] ?? 'No Name',
        'profileImageUrl': requestData['fromUserImageUrl'] ?? '',
        'since': FieldValue.serverTimestamp(),
      });
      batch.set(clientRef.collection('my_stylists').doc(currentUserId), {
        'since': FieldValue.serverTimestamp(),
      });
    }

    // The pending request is always deleted after being handled.
    batch.delete(requestRef);

    // REMOVED: We no longer need to manually update the old 'stylist_stats' counter.
    // The dashboard now counts pending requests in real-time, which is more accurate.

    try {
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${isAccepted ? "Accepted" : "Rejected"}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Operation failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Client Requests')),
        body: const Center(child: Text("Please log in to manage requests.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('New Client Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('client_requests')
                .where('toUserId', isEqualTo: currentUserId)
                .where('status', isEqualTo: 'pending')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No new client requests.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final requests = snapshot.data!.docs;
          return ListView.builder(
            // ... The rest of this UI code is perfect and doesn't need changes ...
            padding: const EdgeInsets.all(8.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requestData =
                  requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 8.0,
                ),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          requestData['fromUserImageUrl'] ??
                              'https://via.placeholder.com/150',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          requestData['fromUsername'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed:
                                () => _handleRequest(
                                  requestData,
                                  requestId,
                                  true,
                                ),
                            child: const Text('Accept'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(80, 36),
                            ),
                          ),
                          const SizedBox(height: 4),
                          OutlinedButton(
                            onPressed:
                                () => _handleRequest(
                                  requestData,
                                  requestId,
                                  false,
                                ),
                            child: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red.shade300),
                              foregroundColor: Colors.red,
                              minimumSize: const Size(80, 36),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
