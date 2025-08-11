import 'package:flutter/material.dart';
import 'reported_posts.dart';      // Your posts grid widget
import 'reported_comments.dart';   // Your comments widget
import 'account_report.dart';      // <-- Import your ReportedAccountsPage widget here

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  static const Color bgColor = Color(0xFFFAE7E7);
  static const Color tabBarColor = Color(0xFFF9E7E9);
  static const Color tabIndicatorColor = Color(0xFF412934); // darkest pink!
  static const Color tabLabelColor = Color(0xFF412934);
  static const Color tabUnselectedLabelColor = Color(0xFF85565E);

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminReportPage.bgColor,
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab bar
            Container(
              color: AdminReportPage.tabBarColor,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AdminReportPage.tabIndicatorColor,
                indicatorWeight: 3,
                labelColor: AdminReportPage.tabIndicatorColor,
                unselectedLabelColor: AdminReportPage.tabUnselectedLabelColor,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'Accounts'),
                  Tab(text: 'Comments'),
                ],
              ),
            ),
            const Divider(height: 0, thickness: 1, color: Color(0xFFE8C3CF)),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  // POSTS TAB (no vertical scroll)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          'Posts',
                          style: TextStyle(
                            fontSize: 20,
                            color: AdminReportPage.tabLabelColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ReportedPostsGrid(isVisible: _tabController.index == 0),
                      const SizedBox(height: 16),
                    ],
                  ),
                  // ACCOUNTS TAB (replaced placeholder with ReportedAccountsPage)
                  ReportedAccountsPage(isVisible: _tabController.index == 1),
                  
                  // COMMENTS TAB (no vertical scroll)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 20,
                            color: AdminReportPage.tabLabelColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ReportedCommentsPage(isVisible: _tabController.index == 2),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
