// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // 1. Define the colors from your palette
  static const Color lightestPink = Color(0xFFF5E9ED); // Background color
  static const Color dustyRose = Color(0xFFD5B9C2); // Accent, borders
  static const Color mauve = Color(0xFF826C71); // Secondary elements
  static const Color primaryMaroon = Color(
    0xFF694953,
  ); // Primary buttons, highlights
  static const Color darkestEggplant = Color(0xFF3D2C32); // Main text color

  // 2. Define the main theme data for the app
  static ThemeData get lightTheme {
    return ThemeData(
      // 3. Set the core color scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryMaroon,
        onPrimary: lightestPink, // Text on primary buttons
        secondary: dustyRose,
        onSecondary: darkestEggplant, // Text on secondary elements
        error: Colors.redAccent,
        onError: Colors.white,
        background: lightestPink, // Main screen background
        onBackground: darkestEggplant, // Main text color on background
        surface: Colors.white, // Color for cards, dialogs
        onSurface: darkestEggplant, // Text on cards
      ),

      // 4. Set scaffold background color
      scaffoldBackgroundColor: lightestPink,

      // 5. Customize the AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: lightestPink, // Clean app bar background
        foregroundColor: darkestEggplant, // Color for title and icons
        elevation: 0, // No shadow for a modern look
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Lora', // Matches your wireframe's font
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: darkestEggplant,
        ),
      ),

      // 6. Customize the Card theme
      // 6. Customize the Card theme
      // --- THIS IS THE CORRECTED LINE ---
      cardTheme: CardThemeData(
        // CORRECTED: Changed from CardTheme to CardThemeData
        elevation: 1.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),

      // 7. Customize the Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMaroon, // Use the primary color
          foregroundColor: lightestPink, // Text color on the button
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryMaroon,
          side: const BorderSide(color: primaryMaroon, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryMaroon),
      ),

      // 8. Customize Text Field theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dustyRose),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryMaroon, width: 2),
        ),
      ),
    );
  }
}
