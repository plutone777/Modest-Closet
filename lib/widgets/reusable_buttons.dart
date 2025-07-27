import 'package:flutter/material.dart';
import 'reusable_widgets.dart'; 

// Reusable Delete Button
class DeleteButton extends StatelessWidget {
  final String itemType; 
  final Future<void> Function() onDelete;

  const DeleteButton({
    super.key,
    required this.itemType,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: "Delete $itemType",
      backgroundColor: const Color.fromARGB(255, 121, 78, 89),
      onPressed: () async {

        final confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete $itemType"),
            content: Text("Are you sure you want to delete this $itemType?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirm == true) {
          try {
            await onDelete();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$itemType deleted successfully")),
            );
            Navigator.pop(context); 
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error deleting $itemType: $e")),
            );
          }
        }
      },
    );
  }
}
