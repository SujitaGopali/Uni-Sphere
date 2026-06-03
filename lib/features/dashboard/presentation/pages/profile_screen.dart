import 'package:flutter/material.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Purple header
          Container(
            width: double.infinity,
            color: AppTheme.primary,
            padding: const EdgeInsets.only(
              top: 56,
              bottom: 32,
              left: 24,
              right: 24,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Student Name',
                  style: TextStyle(
                    fontFamily: AppTheme.fontBold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'student@university.edu',
                  style: TextStyle(
                    fontFamily: AppTheme.fontRegular,
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Placeholder body
          const Expanded(
            child: Center(
              child: Text(
                'Profile settings coming soon.',
                style: TextStyle(
                  fontFamily: AppTheme.fontRegular,
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
