// lib/features/stylist/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _professionController = TextEditingController();

  // Email is usually not editable by the user directly
  final _emailController = TextEditingController();

  final _phoneController = TextEditingController();

  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = true; // Start with loading true
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser == null) {
      // Handle case where user is somehow not logged in
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error: Not logged in.')));
      Navigator.pop(context);
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser!.uid)
              .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['username'] ?? '';
        _professionController.text = data['profession'] ?? '';
        _emailController.text = data['email'] ?? '';
        // Add a check for phone, as it might not exist on all profiles
        _phoneController.text = data['phone'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || currentUser == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.uid)
          .update({
            'username': _nameController.text.trim(),
            'profession': _professionController.text.trim(),
            'phone': _phoneController.text.trim(),
            // We generally don't update email this way for security reasons
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
      Navigator.pop(context); // Go back after saving
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editing Profile')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextFormField(
                        controller: _nameController,
                        label: 'Name',
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _professionController,
                        label: 'Profession',
                      ),
                      const SizedBox(height: 16),
                      // Make the email field read-only
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'Email (cannot be changed)',
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _phoneController,
                        label: 'Phone Number',
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  _isSaving
                                      ? null
                                      : () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                              ),
                              child:
                                  _isSaving
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        filled: !enabled,
        fillColor: Colors.grey[200],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }
}
