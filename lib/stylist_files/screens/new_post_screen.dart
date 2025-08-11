import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({Key? key}) : super(key: key);

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isUploading = false;

  // Get the real, currently logged-in user.
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _sharePost() async {
    // Safety Checks
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post.')),
      );
      return;
    }
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // 1. Upload Image to Firebase Storage in a user-specific folder
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(
        'post_images/${currentUser!.uid}/$fileName',
      );
      final uploadTask = storageRef.putFile(_imageFile!);
      final downloadUrl = await (await uploadTask).ref.getDownloadURL();

      // 2. Fetch the author's details from the 'Users' collection in Firestore
      final userDoc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser!.uid)
              .get();
      final authorName = userDoc.data()?['username'] ?? 'Anonymous Stylist';
      // Add a check for profileImageUrl in the Users document
      final authorImageUrl = userDoc.data()?['profileImageUrl'] ?? '';

      // 3. Create the Post Document in the 'posts' collection
      await FirebaseFirestore.instance.collection('posts').add({
        'authorId': currentUser!.uid, // This is the crucial link
        'postImageUrl': downloadUrl,
        'description': _captionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        'savedBy': [],
        'authorName': authorName,
        'authorImageUrl': authorImageUrl,
        'commentCount': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post shared successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share post: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isUploading)
            TextButton(
              onPressed: _sharePost,
              child: const Text(
                'Share',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: IgnorePointer(
        ignoring: _isUploading,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          _imageFile != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : const Center(
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _captionController,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      border: InputBorder.none,
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            if (_isUploading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
