import 'package:flutter/material.dart';
import 'package:mae_assignment/screens/sister_home.dart';
import 'package:mae_assignment/services/auth.service.dart';
import '/widgets/reusable_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    String? result = await _authService.loginUser(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User data not found in Firestore.")),
      );
    } else if (result.startsWith("error:")) {

      String code = result.replaceFirst("error:", "");
      String message = "Login failed";

      if (code == "user-not-found") {
        message = "No user found for that email.";
      } else if (code == "wrong-password") {
        message = "Wrong password.";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } else {

      if (result == "sister") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const SisterHomePage()));
      } else if (result == "stylist") {
        // add code to navigate to ur homepage
      } else if (result == "moderator") {
        // add code to navigate to ur homepage
      }
    }
  }

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
                child: Icon(
                  Icons.shopping_bag,
                  size: 80,
                  color: const Color.fromARGB(255, 216, 166, 176),
                ),
              ),
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Modest Closet",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Center(
                child: Text(
                  "Log In",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),

              CustomTextField(
                controller: _emailController,
                label: "Email",
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 20),

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

              CustomButton(
                text: "Log In",
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 15),

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
