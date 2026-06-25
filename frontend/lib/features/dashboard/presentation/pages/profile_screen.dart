import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/edit_profile_page.dart';
import 'package:uni_sphere/features/dashboard/presentation/view_model/profile_editor_provider.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;
    final profileState = ref.watch(profileEditorProvider);

    if (!profileState.initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(profileEditorProvider.notifier).initializeFromUser(user);
      });
    }

    final displayName = profileState.initialized
        ? profileState.fullName
        : (user?.name ?? 'Student User');
    final displayEmail = profileState.initialized
        ? profileState.email
        : (user?.email ?? 'student@university.edu');
    final displayStudentId =
        profileState.initialized ? profileState.studentId : 'UNI-2026-001';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: AppTheme.fontBold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Avatar + Name + Email ────────────────────────────────────────
          const SizedBox(height: 32),
          Center(
            child: _ProfileAvatar(
              imageBytes: profileState.profileImageBytes,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: const TextStyle(
              fontFamily: AppTheme.fontBold,
              fontSize: 18,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayEmail,
            style: const TextStyle(
              fontFamily: AppTheme.fontRegular,
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Student ID: $displayStudentId',
              style: const TextStyle(
                fontFamily: AppTheme.fontBold,
                fontSize: 13,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // ── Settings List ─────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _ProfileMenuItem(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
                _ProfileMenuItem.disabled(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change Password',
                ),
                _ProfileMenuItem.disabled(
                  icon: Icons.qr_code_2_rounded,
                  label: 'My QR Code',
                ),
                _ProfileMenuItem.disabled(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                ),
                // ── Logout ──────────────────────────────────────────────────
                _ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  labelColor: const Color(0xFFE53935),
                  iconColor: const Color(0xFFE53935),
                  onTap: () async {
                    final email = user?.email;
                    if (email == null) return;
                    await ref.read(profileEditorProvider.notifier).reset();
                    await ref
                        .read(authViewModelProvider.notifier)
                        .logout(email);
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (_) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Menu Item ─────────────────────────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? labelColor;
  final Color? iconColor;
  final bool enabled;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  }) : enabled = true;

  const _ProfileMenuItem.disabled({
    required this.icon,
    required this.label,
  })  : onTap = null,
        labelColor = const Color(0xFFB8B8B8),
        iconColor = const Color(0xFFB8B8B8),
        enabled = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? const Color(0xFF424242),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.fontBold,
                  fontSize: 15,
                  color: labelColor ?? AppTheme.textDark,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: enabled
                  ? (labelColor ?? const Color(0xFFBDBDBD))
                  : const Color(0xFFD8D8D8),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final Uint8List? imageBytes;

  const _ProfileAvatar({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        imageBytes != null ? MemoryImage(imageBytes!) as ImageProvider : null;

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF9188FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
        image: imageProvider != null
            ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
            : null,
      ),
      child: imageProvider == null
          ? const Icon(
              Icons.person_rounded,
              size: 52,
              color: Colors.white,
            )
          : null,
    );
  }
}
