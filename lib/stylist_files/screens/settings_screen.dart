// lib/features/stylist/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // This is the function that contains the actual logout logic.
  Future<void> _logout() async {
    // 1. Sign out the current user from Firebase Authentication.
    await FirebaseAuth.instance.signOut();

    // 2. After signing out, navigate to the login screen.
    // We use pushNamedAndRemoveUntil to clear all previous screens (like settings, profile, feed, etc.)
    // so the user cannot press the back button to re-enter the app.
    // The '(route) => false' predicate removes every route in the stack.
    if (mounted) {
      // A safety check to ensure the widget is still on screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSectionHeader(context, "Account"),
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: 'Security & Password',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: 'Privacy',
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, "Support & About"),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'Terms and Policies',
            onTap: () {},
          ),
          const Divider(),
          // This is the Log Out button
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: 'Log Out',
            isDestructive: true,
            // THE FIX IS HERE: The onTap now calls our real _logout function.
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // Helper for section headers like "Account"
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper for each individual setting row
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : Colors.black87;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
