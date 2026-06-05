import 'package:flutter/material.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_outlined,
                size: 64,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No events at the moment',
              style: TextStyle(
                fontFamily: AppTheme.fontBold,
                fontSize: 18,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back soon for upcoming\ncampus events.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontRegular,
                fontSize: 14,
                color: AppTheme.textDark,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
