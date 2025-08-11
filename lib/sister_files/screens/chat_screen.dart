import 'package:flutter/material.dart';
import 'package:mae_assignment/sister_files/screens/chats/stylists_list_screen.dart';
import 'package:mae_assignment/sister_files/widgets/reusable_widgets.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
            },
          ),
        ],
      ),

      floatingActionButton: CustomFAB(
        actions: [
          FABAction(
            icon: Icons.person_add,
            label: "Find Stylists",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StylistsListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
