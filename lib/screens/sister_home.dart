import 'package:flutter/material.dart';
import 'closet_screen.dart';

class SisterHomePage extends StatefulWidget {
  const SisterHomePage({super.key});

  @override
  State<SisterHomePage> createState() => _SisterHomePageState();
}

class _SisterHomePageState extends State<SisterHomePage> {
  int _selectedIndex = 0;

  // ✅ Add your screens here
  final List<Widget> _pages = [
    const ClosetScreen(),
    const Center(child: Text("Feed Page")),
    const Center(child: Text("Chat Page")),
    const Center(child: Text("Profile Page")),
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
