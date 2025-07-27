import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mae_assignment/services/upload_service.dart';
import 'package:mae_assignment/widgets/reusable_widgets.dart';
import 'package:mae_assignment/data/closet_data.dart';

class UploadItemScreen extends StatefulWidget {
  final String userId;
  const UploadItemScreen({super.key, required this.userId});

  @override
  State<UploadItemScreen> createState() => _UploadItemScreenState();
}

class _UploadItemScreenState extends State<UploadItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final UploadService _closetService = UploadService();

  String _selectedCategory = ClosetData.categories.first;
  String _selectedSeason = ClosetData.seasons.first;
  String _selectedStyle = ClosetData.styles.first;
  String _selectedFabric = ClosetData.fabricsByCategory[ClosetData.categories.first]!.first;

  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _uploadItem() async {
    if (_selectedImage == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter item details and select an image.")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _closetService.uploadItem(
        name: _nameController.text,
        category: _selectedCategory,
        fabric: _selectedFabric,
        season: _selectedSeason,
        style: _selectedStyle,
        imageFile: _selectedImage!,
        userId: widget.userId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item uploaded successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Item"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Item Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Category dropdown
              CustomDropdown(
                label: "Category",
                value: _selectedCategory,
                items: ClosetData.categories,
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val!;
                    _selectedFabric = ClosetData.fabricsByCategory[_selectedCategory]!.first;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Fabric dropdown
              CustomDropdown(
                label: "Fabric",
                value: _selectedFabric,
                items: ClosetData.fabricsByCategory[_selectedCategory]!,
                onChanged: (val) => setState(() => _selectedFabric = val!),
              ),
              const SizedBox(height: 20),

              // Season dropdown
              CustomDropdown(
                label: "Season",
                value: _selectedSeason,
                items: ClosetData.seasons,
                onChanged: (val) => setState(() => _selectedSeason = val!),
              ),
              const SizedBox(height: 20),

              // Style dropdown
              CustomDropdown(
                label: "Style",
                value: _selectedStyle,
                items: ClosetData.styles,
                onChanged: (val) => setState(() => _selectedStyle = val!),
              ),
              const SizedBox(height: 20),

              // Pick image button
              OutlinedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
                onPressed: _pickImage,
              ),

              // Show selected image
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.file(_selectedImage!, height: 150, fit: BoxFit.cover),
                ),

              const SizedBox(height: 30),

              // Upload button
              _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color.fromARGB(255, 216, 166, 176),
                        ),
                        onPressed: _uploadItem,
                        child: const Text("Save Item", style: TextStyle(fontSize: 18)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
