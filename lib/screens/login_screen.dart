import 'package:flutter/material.dart';
import '/widgets/reusable_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ✅ Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

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

              // ✅ Logo/Icon
              Center(
                child: Icon(
                  Icons.shopping_bag,
                  size: 80,
                  color: const Color.fromARGB(255, 216, 166, 176),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ App Name
              const Center(
                child: Text(
                  "Modest Closet",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ✅ Screen Title
              const Center(
                child: Text(
                  "Log In",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),

              /// ✅ Email field (using reusable widget)
              CustomTextField(
                controller: _emailController,
                label: "Email",
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 20),

              /// ✅ Password field (using reusable widget with toggle)
              CustomTextField(
                controller: _passwordController,
                label: "Password",
                prefixIcon: Icons.lock,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),

              /// ✅ Login Button
              CustomButton(
                text: "Log In",
                onPressed: () {
                  // 🔜 Hook up Firebase login here
                },
              ),
              const SizedBox(height: 15),

              /// ✅ Navigation to Register Screen
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
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
