import 'package:flutter/material.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;
  const AppGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFAE7E7), // lightest pink
            Color(0xFFD3A3AD), // muted pink
            Color(0xFF85565E), // rosy mauve
            Color(0xFF412934), // deep plum (darkest)
          ],
          stops: [0.05, 0.35, 0.75, 1.0],
        ),
      ),
      child: child,
    );
  }
}
