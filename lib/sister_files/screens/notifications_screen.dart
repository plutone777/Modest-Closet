import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mae_assignment/sister_files/controllers/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  final NotificationController _notificationController =
      NotificationController();

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationController.getUserNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong!"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notifDoc = notifications[index];
              final notifData = notifDoc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(
                  notifData['title'] ?? 'No Title',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _formatTimestamp(notifData['createdAt']),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                trailing:
                    notifData['read'] == false
                        ? const Icon(
                          Icons.fiber_manual_record,
                          color: Colors.red,
                          size: 12,
                        )
                        : null,
                onTap: () {
                  _notificationController.markAsRead(notifDoc.id);
                  _showNotificationDetails(context, notifData);
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    return '';
  }

  // Shows notification details
  void _showNotificationDetails(
    BuildContext context,
    Map<String, dynamic> notifData,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(notifData['title'] ?? 'Notification'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notifData['iconUrl'] != null &&
                    notifData['iconUrl'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Image.network(notifData['iconUrl'], height: 80),
                  ),
                Text(notifData['message'] ?? 'No message provided.'),
                const SizedBox(height: 10),
                Text(
                  "🕒 ${_formatTimestamp(notifData['createdAt'])}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
