// lib/app.dart
// Drop-in replacement — wrap your MaterialApp with ProviderScope in main.dart

import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'views/splash_view.dart'; // your existing splash

class UniSphereApp extends StatelessWidget {
  const UniSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniSphere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,          // ← Montserrat + all theme tokens
      home: const SplashView(),       // ← existing flow: splash → onboarding → login → dashboard
    );
  }
}

// ── main.dart (update to) ──────────────────────────────────────────────────
// void main() {
//   runApp(
//     const ProviderScope(       // ← required for Riverpod
//       child: UniSphereApp(),
//     ),
//   );
// }