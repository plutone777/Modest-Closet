import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Theme
import 'package:mae_assignment/stylist_files/theme/app_theme.dart';

// Shared Login & Register screens
import 'login/login_screen.dart';
import 'login/register_screen.dart';

// Stylist screens
import 'stylist_files/screens/stylist_main_screen.dart';

// Sister screens
import 'sister_files/screens/sisterprofile/profile_screen.dart';
import 'sister_files/screens/sisterprofile/edit_profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modest Closet',
      theme: AppTheme.lightTheme,

      initialRoute: '/login',

      routes: {
        // Shared login/register
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // Stylist home
        '/stylist_home': (context) => const StylistMainScreen(),

        // Sister screens
        '/profile': (context) => ProfileScreen(),
        '/editProfile': (context) => const EditProfileScreen(),
      },
    );
  }
}
