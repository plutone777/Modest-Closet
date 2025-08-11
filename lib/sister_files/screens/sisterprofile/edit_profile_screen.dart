import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mae_assignment/sister_files/controllers/user_controller.dart';
import 'package:mae_assignment/sister_files/controllers/image_picker_controller.dart';
import 'package:mae_assignment/sister_files/widgets/reusable_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserController _userController = UserController();
  final ImagePickerController _imagePicker = ImagePickerController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _selectedImage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _userController.getUserDetails();
    setState(() {
      _usernameController.text = userData?["username"] ?? "";
      _emailController.text = _auth.currentUser?.email ?? "";
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    await _imagePicker.pickImage((File? picked) {
      setState(() {
        _selectedImage = picked;
      });
    });
  }

  Future<void> _saveChanges() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saving changes...")),
      );

      await _userController.updateProfile(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim().isNotEmpty
            ? _passwordController.text.trim()
            : null,
        profileImage: _selectedImage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color.fromARGB(255, 216, 166, 176),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromARGB(255, 216, 166, 176),
                      backgroundImage:
                          _selectedImage != null ? FileImage(_selectedImage!) : null,
                      child: _selectedImage == null
                          ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _usernameController,
                    label: "Username",
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _emailController,
                    label: "Email",
                    prefixIcon: Icons.email,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _passwordController,
                    label: "New Password",
                    prefixIcon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  CustomButton(
                    text: "Save Changes",
                    onPressed: _saveChanges,
                  ),
                  const SizedBox(height: 12),

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
