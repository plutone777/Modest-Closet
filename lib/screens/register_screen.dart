import 'package:flutter/material.dart';
import '/widgets/reusable_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _selectedRole = "sister";
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Icon(Icons.shopping_bag, size: 80, color: const Color.fromARGB(255, 216, 166, 176)),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text("Modest Closet", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const Center(
                child: Text("Create Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),

              /// ✅ Using CustomTextField for username
              CustomTextField(
                controller: _usernameController,
                label: "Username",
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 20),

              /// ✅ Using CustomTextField for email
              CustomTextField(
                controller: _emailController,
                label: "Email",
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 20),

              /// ✅ Password field with toggle
              CustomTextField(
                controller: _passwordController,
                label: "Password",
                prefixIcon: Icons.lock,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              /// ✅ Confirm Password field
              CustomTextField(
                controller: _confirmPasswordController,
                label: "Confirm Password",
                prefixIcon: Icons.lock_outline,
                obscureText: !_isConfirmPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              /// ✅ Dropdown stays the same
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: "Select Role",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: "sister", child: Text("Sister")),
                  DropdownMenuItem(value: "stylist", child: Text("Stylist")),
                  DropdownMenuItem(value: "moderator", child: Text("Moderator")),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedRole = val!;
                  });
                },
              ),
              const SizedBox(height: 30),

              /// ✅ Using CustomButton
              CustomButton(
                text: "Sign Up",
                onPressed: () {
                  // 🔜 Hook up Firebase
                },
              ),

              const SizedBox(height: 15),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Already have an account? Log In",
                    style: TextStyle(color: Color.fromARGB(255, 216, 166, 176)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
