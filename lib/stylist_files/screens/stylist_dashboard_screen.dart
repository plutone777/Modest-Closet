// lib/features/stylist/screens/stylist_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mae_assignment/stylist_files/theme/app_theme.dart';

import 'package:mae_assignment/stylist_files/models/stylist_models.dart';
import 'package:mae_assignment/stylist_files/screens/new_client_requests_screen.dart';
import 'package:mae_assignment/stylist_files/screens/notification_screen.dart';

class StylistDashboardScreen extends StatefulWidget {
  const StylistDashboardScreen({super.key});

  @override
  State<StylistDashboardScreen> createState() => _StylistDashboardScreenState();
}

class _StylistDashboardScreenState extends State<StylistDashboardScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _logout());
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Stream<DocumentSnapshot> stylistStatsStream =
        FirebaseFirestore.instance
            .collection('stylist_stats')
            .doc(currentUser!.uid)
            .snapshots();
    final Stream<QuerySnapshot> clientRequestsStream =
        FirebaseFirestore.instance
            .collection('client_requests')
            .where('toUserId', isEqualTo: currentUser!.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots();
    final Stream<QuerySnapshot> unreadNotificationsStream =
        FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.uid)
            .collection('notifications')
            .where('isRead', isEqualTo: false)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: unreadNotificationsStream,
            builder: (context, snapshot) {
              final hasUnread =
                  snapshot.hasData && snapshot.data!.docs.isNotEmpty;
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    if (hasUnread)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app_outlined),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: stylistStatsStream,
        builder: (context, statsSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: clientRequestsStream,
            builder: (context, requestsSnapshot) {
              if (statsSnapshot.connectionState == ConnectionState.waiting ||
                  requestsSnapshot.connectionState == ConnectionState.waiting) {
                return _buildDashboardUI(isLoading: true);
              }
              if (statsSnapshot.hasError || requestsSnapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${statsSnapshot.error ?? requestsSnapshot.error}",
                  ),
                );
              }
              final stats =
                  statsSnapshot.hasData && statsSnapshot.data!.exists
                      ? StylistPerformanceStats.fromFirestore(
                        statsSnapshot.data!,
                      )
                      : StylistPerformanceStats(
                        profileViews: 0,
                        newFollowers: 0,
                        postEngagement: 0,
                      );
              final newClientRequestsCount =
                  requestsSnapshot.hasData
                      ? requestsSnapshot.data!.docs.length
                      : 0;
              return _buildDashboardUI(
                isLoading: false,
                stats: stats,
                newClientRequests: newClientRequestsCount,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDashboardUI({
    required bool isLoading,
    StylistPerformanceStats? stats,
    int newClientRequests = 0,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap:
                isLoading
                    ? null
                    : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewClientRequestsScreen(),
                      ),
                    ),
            child: _StyledCard(
              value: isLoading ? '...' : '+$newClientRequests',
              label: 'New Client Requests',
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "This Week's Performance",
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkestEggplant,
            ),
          ),
          const SizedBox(height: 16),
          _StyledCard(
            value:
                isLoading
                    ? '...'
                    : NumberFormat.decimalPattern().format(
                      stats?.profileViews ?? 0,
                    ),
            label: 'Profile Views',
          ),
          const SizedBox(height: 16),
          _StyledCard(
            value: isLoading ? '...' : '+${stats?.newFollowers ?? 0}',
            label: 'New Followers',
          ),
          const SizedBox(height: 16),
          _StyledCard(
            value: isLoading ? '...' : '${stats?.postEngagement ?? 0}%',
            label: 'Post Engagement',
          ),
        ],
      ),
    );
  }
}

// --- THIS IS THE CORRECTED CARD WIDGET ---
class _StyledCard extends StatelessWidget {
  final String value;
  final String label;

  const _StyledCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: const Offset(5, 5),
          child: Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.darkestEggplant,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 90,
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjusted padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkestEggplant, width: 2),
          ),
          child: Center(
            // Center the content vertically
            child: Column(
              mainAxisSize: MainAxisSize.min, // Take up minimum vertical space
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppTheme.darkestEggplant,
                  ),
                ),
                const SizedBox(height: 4),
                // FittedBox prevents the label from overflowing
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: AppTheme.mauve),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
