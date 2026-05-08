import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Required blue background for UniSphere
    const uniBlue = Color(0xFF4A55A2);

    return const Scaffold(
      backgroundColor: uniBlue,
      body: Center(
        child: Text(
          'Hello',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}