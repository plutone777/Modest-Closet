// lib/features/stylist/widgets/shared_app_bar.dart

import 'package:flutter/material.dart';
// Import the screen that the handshake icon will navigate to.
import 'package:mae_assignment/stylist_files/screens/my_clients_screen.dart';

/// A reusable, shared AppBar for the application.
///
/// [context] is the BuildContext from the screen where the AppBar is used.
/// [title] is the String to display in the AppBar title.
/// [showClientListIcon] is an optional boolean to show the "My Clients" (handshake) icon button.
AppBar sharedAppBar(
  BuildContext context,
  String title, {
  bool showClientListIcon = false,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.white,
    elevation: 1, // Adds a subtle shadow for depth
    // This ensures that any automatically added icons (like a back arrow) are also black.
    iconTheme: const IconThemeData(color: Colors.black),
    actions: [
      // This is a conditional list element. The IconButton will only be added
      // to the 'actions' list if the 'showClientListIcon' flag is true.
      if (showClientListIcon)
        IconButton(
          icon: const Icon(Icons.handshake_outlined, color: Colors.black),
          tooltip: 'My Clients',
          onPressed: () {
            // --- THIS IS THE FULLY IMPLEMENTED NAVIGATION ---
            // When the icon is pressed, it navigates to the MyClientsScreen.
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MyClientsScreen()),
            );
            // --- END OF IMPLEMENTATION ---
          },
        ),
    ],
  );
}
