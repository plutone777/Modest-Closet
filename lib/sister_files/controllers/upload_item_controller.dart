import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mae_assignment/sister_files/controllers/item_upload_service.dart';
import 'package:mae_assignment/sister_files/data/closet_data.dart';
import 'image_picker_controller.dart';

class UploadItemController {
  final TextEditingController nameController = TextEditingController();
  final UploadService closetService = UploadService();
  final ImagePickerController imagePicker = ImagePickerController();

  String selectedCategory = ClosetData.categories.first;
  String selectedSeason = ClosetData.seasons.first;
  String selectedStyle = ClosetData.styles.first;
  String selectedFabric =
      ClosetData.fabricsByCategory[ClosetData.categories.first]!.first;

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
    selectedFabric =
        existingFabric ?? ClosetData.fabricsByCategory[selectedCategory]!.first;
    selectedSeason = existingSeason ?? ClosetData.seasons.first;
    selectedStyle = existingStyle ?? ClosetData.styles.first;
  }

  Future<void> saveItem({
    required String userId,
    String? itemId,
    String? existingImageUrl,
    required BuildContext context,
    File? pickedImage,
  }) async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter item details.")),
      );
      return;
    }

    isUploading = true;

    try {
      // CASE 1: NEW ITEM UPLOAD
      if (itemId == null) {
        if (pickedImage == null) {
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
          imageFile: pickedImage, 
          userId: userId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item uploaded successfully!")),
        );
      }
      // CASE 2: UPDATE EXISTING ITEM
      else {
        await closetService.updateItem(
          itemId: itemId,
          name: nameController.text,
          category: selectedCategory,
          fabric: selectedFabric,
          season: selectedSeason,
          style: selectedStyle,
          newImageFile: pickedImage,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item updated successfully!")),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Save failed: $e")));
    } finally {
      isUploading = false;
    }
  }
}
