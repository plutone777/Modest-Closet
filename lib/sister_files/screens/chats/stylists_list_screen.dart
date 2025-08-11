import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mae_assignment/sister_files/controllers/chat_controller.dart';
import 'package:mae_assignment/sister_files/controllers/user_controller.dart';

class StylistsListScreen extends StatelessWidget {
  const StylistsListScreen({super.key});

  void _showRequestBottomSheet(
      BuildContext context, String stylistName, String stylistId) {
    final ChatRequestController requestController = ChatRequestController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Send a message request to $stylistName?",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text("Send Request"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 216, 166, 176),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () async {
                  final result = await requestController.sendMessageRequest(stylistId);
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = UserController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stylists"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userController.getStylistsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No stylists available.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final stylists = snapshot.data!.docs;

          return ListView.builder(
            itemCount: stylists.length,
            itemBuilder: (context, index) {
              final stylist = stylists[index].data() as Map<String, dynamic>;
              final stylistId = stylists[index].id;
              final username = stylist['username'] ?? 'Unknown Stylist';
              final specialty = stylist['specialty'] ?? 'No specialty provided';
              final profileIcon = stylist['profileIcon'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (profileIcon != null && profileIcon.isNotEmpty)
                      ? NetworkImage(profileIcon)
                      : null,
                  child: (profileIcon == null || profileIcon.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(username),
                subtitle: Text(specialty),
                onTap: () {
                  _showRequestBottomSheet(context, username, stylistId);
                },
              );
            },
          );
        },
      ),
    );
  }
}
