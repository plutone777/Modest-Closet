import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerController {
  File? selectedImage;

  // Pick image from gallery
  Future<void> pickImage(Function(File?) onImagePicked) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      onImagePicked(selectedImage);
    }
  }

  void clearImage() {
    selectedImage = null;
  }
}
