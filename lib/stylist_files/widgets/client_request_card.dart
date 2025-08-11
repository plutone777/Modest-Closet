// lib/features/stylist/widgets/client_request_card.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mae_assignment/stylist_files/models/stylist_models.dart';

class ClientRequestCard extends StatelessWidget {
  final ClientRequest request;

  const ClientRequestCard({
    Key? key,
    required this.request,
  }) : super(key: key);

  // Function to handle accepting a request
  void _acceptRequest(BuildContext context) {
    // TODO: In a real app, you would move this user to a 'clients' collection
    // For now, we'll just delete the request.
    FirebaseFirestore.instance.collection('client_requests').doc(request.id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Accepted ${request.name}')));
  }

  // Function to handle rejecting a request
  void _rejectRequest(BuildContext context) {
    // This will delete the request document from Firestore
    FirebaseFirestore.instance.collection('client_requests').doc(request.id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejected ${request.name}')));
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(request.imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${request.age}, ${request.profession}',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _acceptRequest(context),
                  child: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(80, 36),
                  ),
                ),
                const SizedBox(height: 4),
                OutlinedButton(
                  onPressed: () => _rejectRequest(context),
                  child: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    foregroundColor: Colors.red,
                    minimumSize: const Size(80, 36),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}