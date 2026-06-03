import 'package:flutter/material.dart';
import 'package:uni_sphere/features/splash/presentation/pages/splash_page.dart';
import 'package:uni_sphere/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:uni_sphere/features/auth/presentation/pages/login_page.dart';
import 'package:uni_sphere/features/auth/presentation/pages/signup_page.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/dashboard_page.dart';
import 'themes/app_theme.dart';

class UniSphereApp extends StatelessWidget {
  const UniSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniSphere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashPage(),
      routes: {
        '/splash': (context) => const SplashPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
