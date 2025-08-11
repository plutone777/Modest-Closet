import 'package:flutter/material.dart';
import 'app_gradient_background.dart';
import 'custom_top_bar.dart';
import 'admin_feed_page.dart';
import 'admin_report_page.dart'; // Report page with tabs
import 'review_account_page.dart'; // <-- Import ReviewAccountsPage

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  static const Color navBar = Color(0xFFD3A3AD);
  static const Color iconSelected = Color(0xFF412934);
  static const Color iconUnselected = Color(0xFF412934);

  final List<Widget> _pages = const [
    AdminFeedPage(),
    AdminReportPage(), // Report page with tabs
    ReviewAccountsPage(), // The review page widget from report_account_page.dart
  ];

  String? _modalPostTitle;

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomTopBar(
          title: _modalPostTitle ??
              (_currentIndex == 0
                  ? "Feed"
                  : _currentIndex == 1
                      ? "Report page"
                      : "Review"),
        ),
        body: Stack(
          children: [
            _pages[_currentIndex],
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: navBar.withOpacity(0.8),
          currentIndex: _currentIndex,
          selectedItemColor: iconSelected,
          unselectedItemColor: iconUnselected,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF412934),
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Color(0xFF412934),
          ),
          onTap: (index) => setState(() {
            _modalPostTitle = null;
            _currentIndex = index;
          }),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_drive_file_rounded, color: Color(0xFF412934)),
              label: "Feed",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Color(0xFF412934)),
              label: "Report page",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border_rounded, color: Color(0xFF412934)),
              label: "Review",
            ),
          ],
        ),
      ),
    );
  }
}
