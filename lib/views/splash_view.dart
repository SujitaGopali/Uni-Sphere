import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_sphere/views/onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Keeps the original 2-second transition logic
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF4A55A2); // Updated to match the screenshot blue

    return Scaffold(
      backgroundColor: Colors.white, // Matches the new white background
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular container for the logo as seen in the image
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded, // Graduation cap style icon
                size: 100,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'UniSphere',
              style: TextStyle(
                color: primaryBlue,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Campus. Your Events.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}