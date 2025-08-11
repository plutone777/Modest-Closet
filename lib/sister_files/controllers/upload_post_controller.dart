import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mae_assignment/sister_files/controllers/image_picker_controller.dart';
import 'dart:io';

class UploadPostController {
  final TextEditingController descriptionController = TextEditingController();
  final ImagePickerController imageController = ImagePickerController();

  bool allowComments = true;

  // PICK IMAGE
  Future<void> pickImage(Function refreshUI) async {
    await imageController.pickImage((File? pickedFile) {
      refreshUI();
    });
  }

  // SAVE NEW POST
  Future<void> savePost({
    required BuildContext context,
    required String userId,
  }) async {
    if (imageController.selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image.")),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploading post...")),
      );

      File imageFile = imageController.selectedImage!;
      String fileName = "posts/${DateTime.now().millisecondsSinceEpoch}.jpg";

      UploadTask uploadTask =
          FirebaseStorage.instance.ref().child(fileName).putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("Posts").add({
        "userId": userId,
        "imageUrl": downloadUrl,
        "description": descriptionController.text.trim(),
        "allowComments": allowComments,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post uploaded successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }
  }

  // EDIT POST DESCRIPTION
  Future<void> editPostDescription({
    required String postId,
    required String newDescription,
    required BuildContext context,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("Posts")
          .doc(postId)
          .update({"description": newDescription.trim()});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Description updated!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    }
  }

  // DELETE POST 
  Future<void> deletePost({
    required String postId,
    required BuildContext context,
  }) async {
    try {
      await FirebaseFirestore.instance.collection("Posts").doc(postId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post deleted!")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: $e")),
      );
    }
  }
}
