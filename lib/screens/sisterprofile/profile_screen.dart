import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mae_assignment/controllers/user_controller.dart'; // ✅ merged controller
import 'package:mae_assignment/widgets/reusable_widgets.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final UserController _controller = UserController(); // ✅ use merged controller
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: _controller.getUserProfileStream(), // ✅ now from UserController
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Profile not found"));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color.fromARGB(255, 216, 166, 176),
                  backgroundImage: (userData["profileIcon"] != null && userData["profileIcon"] != "")
                      ? NetworkImage(userData["profileIcon"])
                      : null,
                  child: (userData["profileIcon"] == null || userData["profileIcon"] == "")
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 20),

                Text(
                  userData["username"] ?? "No Name",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),

                Text(
                  userData["email"] ?? "No Email",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                CustomButton(
                  text: "Edit Profile",
                  onPressed: () {
                    Navigator.pushNamed(context, "/editProfile");
                  },
                ),
                const SizedBox(height: 12),

                CustomButton(
                  text: "Logout",
                  backgroundColor: const Color.fromARGB(255, 121, 78, 89),
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
