import 'package:flutter/material.dart';
import 'package:uni_sphere/features/auth/presentation/pages/login_page.dart';
import 'package:uni_sphere/features/auth/presentation/pages/signup_page.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:uni_sphere/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:uni_sphere/features/splash/presentation/pages/splashscreen.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniSphere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashView(),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
