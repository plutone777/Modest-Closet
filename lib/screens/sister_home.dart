import 'package:flutter/material.dart';
import 'package:mae_assignment/screens/closet_screen.dart';
import 'package:mae_assignment/screens/feed_screen.dart';
import 'package:mae_assignment/screens/profile_screen.dart';

class SisterHomePage extends StatefulWidget {
  const SisterHomePage({super.key});

  @override
  State<SisterHomePage> createState() => _SisterHomePageState();
}

class _SisterHomePageState extends State<SisterHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ClosetScreen(),
    FeedScreen(),
    const Center(child: Text("Chat Page")),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 216, 166, 176),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: "Closet"),
          BottomNavigationBarItem(icon: Icon(Icons.dynamic_feed), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
