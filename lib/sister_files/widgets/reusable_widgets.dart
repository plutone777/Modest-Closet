import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Reusable TextField widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// Reusable Button widget
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color.fromARGB(255, 216, 166, 176),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Reusable Dropdown Widget
class CustomDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }
}

// Reusable Empty State Widget
class CustomEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const CustomEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.checkroom,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Reusable Clothing Card
class ClothingCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String category;
  final VoidCallback? onTap;

  const ClothingCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, 
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    category,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
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

// Reusable FAB
class CustomFAB extends StatelessWidget {
  final List<FABAction> actions;
  final Color fabColor;
  final IconData fabIcon;

  const CustomFAB({
    super.key,
    required this.actions,
    this.fabColor = const Color.fromARGB(255, 216, 166, 176),
    this.fabIcon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: fabColor,
      child: Icon(fabIcon, color: Colors.white),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Wrap(
            children: actions.map((action) {
              return ListTile(
                leading: Icon(action.icon, color: Colors.black87),
                title: Text(action.label),
                onTap: () {
                  Navigator.pop(context); 
                  action.onTap();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class FABAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  FABAction({required this.label, required this.icon, required this.onTap});
}

// Reusable Outfit Card
class OutfitCard extends StatelessWidget {
  final String outfitName;
  final List<String> imageUrls;
  final VoidCallback onTap;

  const OutfitCard({
    super.key,
    required this.outfitName,
    required this.imageUrls,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                outfitName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              imageUrls.isEmpty
                  ? const Text("No items found for this outfit")
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: imageUrls.map((url) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                url,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable PostCard
class PostCard extends StatelessWidget {
  final String imageUrl;
  final String description;
  final bool allowComments;
  final String userId;

  const PostCard({
    super.key,
    required this.imageUrl,
    required this.description,
    required this.allowComments,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text("Loading..."),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final profileIcon = userData['profileIcon'] ?? '';
              final username = userData['username'] ?? 'Unknown';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      profileIcon.isNotEmpty ? NetworkImage(profileIcon) : null,
                  backgroundColor: const Color.fromARGB(255, 216, 166, 176),
                  child: profileIcon.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(description),
          ),
        ],
      ),
    );
  }
}

// Reusable PostCard for Own Posts
class OwnPostCard extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const OwnPostCard({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), 
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

// Reusable Notification Icon
class NotificationIcon extends StatelessWidget {
  final VoidCallback onTap;  

  const NotificationIcon({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: onTap,
    );
  }
}
