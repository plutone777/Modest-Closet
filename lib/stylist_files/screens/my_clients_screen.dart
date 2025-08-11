// lib/features/stylist/screens/my_clients_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_detail_screen.dart';
import 'user_profile_screen.dart'; // <-- 1. IMPORT THE USER PROFILE SCREEN

class MyClientsScreen extends StatefulWidget {
  const MyClientsScreen({super.key});

  @override
  State<MyClientsScreen> createState() => _MyClientsScreenState();
}

class _MyClientsScreenState extends State<MyClientsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Clients')),
      body:
          currentUser == null
              ? const Center(child: Text("Please log in to see your clients."))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc(currentUser!.uid)
                        .collection('clients')
                        .orderBy('since', descending: true)
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
                        "You have no clients yet.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  final clients = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final clientData =
                          clients[index].data() as Map<String, dynamic>;
                      final clientId = clients[index].id;
                      final clientName = clientData['username'] ?? 'No Name';
                      final clientImageUrl =
                          clientData['profileImageUrl'] ?? '';

                      return ListTile(
                        // --- 2. THE CHANGE IS HERE ---
                        // We wrap the CircleAvatar in a GestureDetector to make it tappable.
                        leading: GestureDetector(
                          onTap: () {
                            // This tap action navigates to the client's profile.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        UserProfileScreen(userId: clientId),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage:
                                clientImageUrl.isNotEmpty
                                    ? NetworkImage(clientImageUrl)
                                    : null,
                            child:
                                clientImageUrl.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                          ),
                        ),
                        // --- END OF CHANGE ---
                        title: Text(clientName),
                        subtitle: const Text("Client"),
                        trailing: const Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                        ),
                        // The main ListTile still navigates to the chat screen.
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatDetailScreen(
                                      chatPartnerId: clientId,
                                      chatPartnerName: clientName,
                                      chatPartnerImageUrl: clientImageUrl,
                                    ),
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
