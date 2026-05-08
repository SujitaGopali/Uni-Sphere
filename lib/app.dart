import 'package:flutter/material.dart';
import 'package:uni_sphere/views/splash_view.dart';

class UniSphereApp extends StatelessWidget {
  const UniSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the "Nice Blue" primary color for UniSphere
    const primaryBlue = Color(0xFF0052D4);
    const secondaryBlue = Color(0xFF4361EE);

    return MaterialApp(
      title: 'UniSphere',
      debugShowCheckedModeBanner: false,
      
      // Global Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: secondaryBlue,
          surface: Colors.white,
        ),
        
        // Applying the theme to all text fields (similar to your uploaded code)
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryBlue, width: 2),
          ),
          labelStyle: TextStyle(color: primaryBlue),
          prefixIconColor: primaryBlue,
        ),

        // Styling for the "FilledButton" used in your Login and Signup views
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Customizing the AppBar for the project
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      // Starting the app with the SplashView
      home: const SplashView(),
    );
  }
}