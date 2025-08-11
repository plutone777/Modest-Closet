import 'package:flutter/material.dart';
import 'package:mae_assignment/sister_files/controllers/upload_item_controller.dart';
import 'package:mae_assignment/sister_files/widgets/reusable_image_uploader.dart';
import 'package:mae_assignment/sister_files/widgets/reusable_widgets.dart';
import 'package:mae_assignment/sister_files/data/closet_data.dart';
import 'package:mae_assignment/sister_files/controllers/image_picker_controller.dart';

class UploadItemScreen extends StatefulWidget {
  final String userId;

  // Extra fields for edit mode
  final String? itemId;
  final String? existingImageUrl;
  final String? existingName;
  final String? existingCategory;
  final String? existingFabric;
  final String? existingSeason;
  final String? existingStyle;

  const UploadItemScreen({
    super.key,
    required this.userId,
    this.itemId,
    this.existingImageUrl,
    this.existingName,
    this.existingCategory,
    this.existingFabric,
    this.existingSeason,
    this.existingStyle,
  });

  @override
  State<UploadItemScreen> createState() => _UploadItemScreenState();
}

class _UploadItemScreenState extends State<UploadItemScreen> {
  final UploadItemController _controller = UploadItemController();
  final ImagePickerController _imageController = ImagePickerController();


  @override
  void initState() {
    super.initState();

    if (widget.itemId != null) {
      _controller.initializeEditData(
        existingName: widget.existingName,
        existingCategory: widget.existingCategory,
        existingFabric: widget.existingFabric,
        existingSeason: widget.existingSeason,
        existingStyle: widget.existingStyle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.itemId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Item" : "Upload Item"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextField(
                controller: _controller.nameController,
                decoration: InputDecoration(
                  labelText: "Item Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              CustomDropdown(
                label: "Category",
                value: _controller.selectedCategory,
                items: ClosetData.categories,
                onChanged: (val) {
                  setState(() {
                    _controller.selectedCategory = val!;
                    _controller.selectedFabric =
                        ClosetData.fabricsByCategory[_controller.selectedCategory]!.first;
                  });
                },
              ),
              const SizedBox(height: 20),

              CustomDropdown(
                label: "Fabric",
                value: _controller.selectedFabric,
                items: ClosetData.fabricsByCategory[_controller.selectedCategory]!,
                onChanged: (val) => setState(() => _controller.selectedFabric = val!),
              ),
              const SizedBox(height: 20),

              CustomDropdown(
                label: "Season",
                value: _controller.selectedSeason,
                items: ClosetData.seasons,
                onChanged: (val) => setState(() => _controller.selectedSeason = val!),
              ),
              const SizedBox(height: 20),

              CustomDropdown(
                label: "Style",
                value: _controller.selectedStyle,
                items: ClosetData.styles,
                onChanged: (val) => setState(() => _controller.selectedStyle = val!),
              ),
              const SizedBox(height: 20),

              UploadImageArea(
                imageFile: _imageController.selectedImage,
                existingImageUrl: widget.existingImageUrl,
                onTap: () => _imageController.pickImage((pickedFile) {
                  setState(() {});
                }),
              ),

              const SizedBox(height: 30),

              // SAVE BUTTON
              _controller.isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: isEditMode ? "Save Changes" : "Save Item",
                      onPressed: () => _controller.saveItem(
                        userId: widget.userId,
                        itemId: widget.itemId,
                        existingImageUrl: widget.existingImageUrl,
                        context: context,
                        pickedImage: _imageController.selectedImage, 
                      ),
                    ),
                    const SizedBox(height: 10),

              // CANCEL BUTTON (only for edit mode)
              if (isEditMode)
                CustomButton(
                  text: "Cancel",
                  backgroundColor: Color.fromARGB(255, 121, 78, 89),
                  onPressed: () => Navigator.pop(context),
                ),

            ],
          ),
        ),
      ),
    );
  }
}
