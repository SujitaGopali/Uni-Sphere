import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;

    return ColoredBox(
      color: AppTheme.background,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primary,
            padding: const EdgeInsets.only(
              top: 24,
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
                Text(
                  user?.name ?? 'Student Name',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontBold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'student@university.edu',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontRegular,
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
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
