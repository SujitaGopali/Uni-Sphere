import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/core/services/auto_brightness_provider.dart';
import 'package:uni_sphere/features/auth/presentation/pages/login_page.dart';
import 'package:uni_sphere/features/auth/presentation/pages/signup_page.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:uni_sphere/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:uni_sphere/features/splash/presentation/pages/splashscreen.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep provider alive so sensor listening starts after restore.
    ref.watch(autoBrightnessProvider);

    return MaterialApp(
      title: 'UniSphere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashView(),
      routes: {
        '/landing': (context) => const LandingPage(),
        '/onboarding': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
