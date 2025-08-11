// lib/features/stylist/screens/stylist_main_screen.dart

import 'package:flutter/material.dart';

// Import all the real, dynamic screens you have created.
// Make sure these file names match exactly what you have in your project.
import 'stylist_dashboard_screen.dart';
import '../../stylist_files/screens/feed_screen.dart'; // The dynamic feed screen we've been fixing
import 'messaging_screen.dart'; // Using the name from the file you provided
import 'stylist_profile_screen.dart';
import 'new_post_screen.dart';

class StylistMainScreen extends StatefulWidget {
  const StylistMainScreen({Key? key}) : super(key: key);

  @override
  State<StylistMainScreen> createState() => _StylistMainScreenState();
}

class _StylistMainScreenState extends State<StylistMainScreen> {
  // We start on the Feed screen (index 1) by default.
  int _pageIndex = 1;

  // This is the list of your primary screens.
  // We use the real, dynamic FeedScreen that is connected to Firebase.
  static final List<Widget> _pages = <Widget>[
    StylistDashboardScreen(), // Corresponds to index 0
    FeedScreen(), // Corresponds to index 1
    MessagesListScreen(), // Corresponds to index 2
    StylistProfileScreen(), // Corresponds to index 3
  ];

  void _onItemTapped(int index) {
    // Special case for the middle "Add" button, which has index 2.
    // It should not change the current screen, but open a new one on top.
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NewPostScreen(),
          fullscreenDialog:
              true, // This makes it slide up from the bottom on iOS.
        ),
      );
      return; // Stop the function here so it doesn't change the page index.
    }

    // For all other buttons, update the state to show the new screen.
    setState(() {
      // This logic maps the 5-button navbar to our 4-page list.
      if (index < 2) {
        // Tapped Home (0) or Feed (1)
        _pageIndex = index;
      } else {
        // Tapped Messages (3) or Profile (4)
        // We subtract 1 to get the correct index for our _pages list.
        _pageIndex = index - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate which bottom nav bar icon should be highlighted.
    // This is the reverse of the logic in _onItemTapped.
    int bottomNavBarIndex = _pageIndex;
    if (_pageIndex >= 2) {
      bottomNavBarIndex = _pageIndex + 1; // Adjust for the "+" button gap.
    }

    return Scaffold(
      // IndexedStack is the best widget for this. It keeps all pages in the
      // widget tree, preserving their state (like scroll position) when you switch.
      body: IndexedStack(index: _pageIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            activeIcon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed_outlined),
            label: 'Feed',
            activeIcon: Icon(Icons.dynamic_feed),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 32),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Messages',
            activeIcon: Icon(Icons.chat_bubble),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
            activeIcon: Icon(Icons.person),
          ),
        ],
        currentIndex: bottomNavBarIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade600,
        elevation: 2.0,
      ),
    );
  }
}
