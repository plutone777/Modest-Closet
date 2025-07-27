import 'package:flutter/material.dart';
import 'package:mae_assignment/controllers/upload_post_controller.dart';
import 'package:mae_assignment/widgets/reusable_widgets.dart';
import 'package:mae_assignment/widgets/reusable_image_uploader.dart';

class UploadPostScreen extends StatefulWidget {
  final String userId;
  const UploadPostScreen({super.key, required this.userId});

  @override
  State<UploadPostScreen> createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  final UploadPostController _controller = UploadPostController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Post"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UploadImageArea(
              imageFile: _controller.imageController.selectedImage,
              onTap: () => _controller.pickImage(() => setState(() {})),
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _controller.descriptionController,
              label: "Post Description",
              prefixIcon: Icons.description,
            ),
            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text("Allow Comments"),
              value: _controller.allowComments,
              onChanged: (val) {
                setState(() {
                  _controller.allowComments = val;
                });
              },
            ),
            const SizedBox(height: 20),

            CustomButton(
              text: "Upload Post",
              onPressed: () => _controller.savePost(
                context: context,
                userId: widget.userId,
              ),
            ),
            const SizedBox(height: 10),

            CustomButton(
              text: "Cancel",
              backgroundColor: const Color.fromARGB(255, 121, 78, 89),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
