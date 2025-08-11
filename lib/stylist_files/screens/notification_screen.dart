// lib/features/stylist/screens/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mae_assignment/stylist_files/theme/app_theme.dart';
import 'package:mae_assignment/stylist_files/models/stylist_models.dart';

// --- CHANGE 1: Converted to a StatefulWidget ---
// This is necessary to run code when the screen first loads (in initState).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // --- CHANGE 2: Mark all notifications as read when the screen is opened ---
    _markAllAsRead();
  }

  // This function finds all unread notifications and updates them in a single batch.
  Future<void> _markAllAsRead() async {
    if (currentUser == null) return;

    final notificationsRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('notifications');

    // Find all notifications that are currently unread.
    final unreadQuery =
        await notificationsRef.where('isRead', isEqualTo: false).get();

    if (unreadQuery.docs.isEmpty) {
      return; // Nothing to mark.
    }

    // Use a WriteBatch for efficiency to update all documents at once.
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in unreadQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // The delete function remains the same.
  Future<void> _deleteNotification(String notificationId) async {
    // ... (This function is correct and needs no changes)
    if (currentUser == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.uid)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not remove notification: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text("Please log in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Users')
                .doc(currentUser!.uid)
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(color: Colors.grey),
              ),
            );

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final notification = NotificationItem.fromFirestore(
                snapshot.data!.docs[index],
              );
              // The card color will now update automatically when 'isRead' becomes true.
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color:
                    notification.isRead
                        ? Theme.of(context).cardTheme.color
                        : Colors.blue.shade50,
                child: ListTile(
                  title: Text(
                    notification.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMM d, yyyy \'at\' h:mm a',
                        ).format(notification.timestamp.toDate()),
                        style: TextStyle(
                          color: AppTheme.mauve.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.mauve,
                    ),
                    tooltip: 'Dismiss Notification',
                    onPressed: () => _deleteNotification(notification.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
