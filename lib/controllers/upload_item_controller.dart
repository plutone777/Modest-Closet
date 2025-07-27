import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mae_assignment/services/upload_service.dart';
import 'package:mae_assignment/data/closet_data.dart';

class UploadItemController {
  final TextEditingController nameController = TextEditingController();
  final UploadService closetService = UploadService();

  String selectedCategory = ClosetData.categories.first;
  String selectedSeason = ClosetData.seasons.first;
  String selectedStyle = ClosetData.styles.first;
  String selectedFabric = ClosetData.fabricsByCategory[ClosetData.categories.first]!.first;

  File? selectedImage;
  bool isUploading = false;

  void initializeEditData({
    String? existingName,
    String? existingCategory,
    String? existingFabric,
    String? existingSeason,
    String? existingStyle,
  }) {
    nameController.text = existingName ?? "";
    selectedCategory = existingCategory ?? ClosetData.categories.first;
    selectedFabric = existingFabric ?? ClosetData.fabricsByCategory[selectedCategory]!.first;
    selectedSeason = existingSeason ?? ClosetData.seasons.first;
    selectedStyle = existingStyle ?? ClosetData.styles.first;
  }

  Future<void> pickImage(Function(File?) onImagePicked) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      onImagePicked(selectedImage);
    }
  }

  Future<void> saveItem({
    required String userId,
    String? itemId,
    String? existingImageUrl,
    required BuildContext context,
  }) async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter item details.")),
      );
      return;
    }

    isUploading = true;

    try {
      if (itemId == null) {

        if (selectedImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select an image.")),
          );
          return;
        }

        await closetService.uploadItem(
          name: nameController.text,
          category: selectedCategory,
          fabric: selectedFabric,
          season: selectedSeason,
          style: selectedStyle,
          imageFile: selectedImage!,
          userId: userId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item uploaded successfully!")),
        );
      } else {

        await closetService.updateItem(
          itemId: itemId,
          name: nameController.text,
          category: selectedCategory,
          fabric: selectedFabric,
          season: selectedSeason,
          style: selectedStyle,
          newImageFile: selectedImage,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item updated successfully!")),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    } finally {
      isUploading = false;
    }
  }
}
