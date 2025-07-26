import 'package:flutter/material.dart';

class SisterHomePage extends StatefulWidget {
  const SisterHomePage({super.key});

  @override
  State<SisterHomePage> createState() => _SisterHomePageState();
}

class _SisterHomePageState extends State<SisterHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text("Closet Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("Feed Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("Chat Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("Profile Page", style: TextStyle(fontSize: 22))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 216, 166, 176),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: "Closet"),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
