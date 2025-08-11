import 'dart:io';
import 'package:flutter/material.dart';
class UploadImageArea extends StatelessWidget {
  final File? imageFile;
  final String? existingImageUrl;
  final VoidCallback onTap;
  final String label;
  final double height;

  const UploadImageArea({
    Key? key,
    required this.onTap,
    this.imageFile,
    this.existingImageUrl,
    this.label = "Upload Image",
    this.height = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          imageFile!,
          fit: BoxFit.contain,  
          width: double.infinity,
        ),

      );
    } else if (existingImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
          child: Image.network(
            existingImageUrl!,
            fit: BoxFit.contain,   
            width: double.infinity,
          ),

      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, size: 40, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          ],
        ),
      );
    }
  }
}
