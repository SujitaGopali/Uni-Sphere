import 'package:flutter/material.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Explore',
          style: TextStyle(
            fontFamily: AppTheme.fontBold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A5AE0), Color(0xFF8B7FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover campus vibes',
                          style: TextStyle(
                            fontFamily: AppTheme.fontExtraBold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Browse categories and featured events.\nPreview only for now.',
                          style: TextStyle(
                            fontFamily: AppTheme.fontRegular,
                            fontSize: 13,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.explore_rounded, color: Colors.white, size: 44),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Categories',
              style: TextStyle(
                fontFamily: AppTheme.fontBold,
                fontSize: 18,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 14),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _CategoryChip(
                  icon: Icons.laptop_mac_outlined,
                  label: 'Technology',
                  color: Color(0xFFE8EAF6),
                  iconColor: Color(0xFF5C6BC0),
                ),
                _CategoryChip(
                  icon: Icons.music_note_rounded,
                  label: 'Culture',
                  color: Color(0xFFFCE4EC),
                  iconColor: Color(0xFFE91E63),
                ),
                _CategoryChip(
                  icon: Icons.sports_basketball_rounded,
                  label: 'Sports',
                  color: Color(0xFFF1F8E9),
                  iconColor: Color(0xFF558B2F),
                ),
                _CategoryChip(
                  icon: Icons.school_outlined,
                  label: 'Workshop',
                  color: Color(0xFFFFF3E0),
                  iconColor: Color(0xFFFB8C00),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Featured',
              style: TextStyle(
                fontFamily: AppTheme.fontBold,
                fontSize: 18,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 14),
            const _ExploreCard(
              title: 'Tech Talk 2024',
              subtitle: 'Seminar Hall • 2 May 2026',
              accent: Color(0xFF5C6BC0),
              icon: Icons.mic_none_rounded,
            ),
            const SizedBox(height: 12),
            const _ExploreCard(
              title: 'Cultural Fest',
              subtitle: 'Open Auditorium • 6 May 2026',
              accent: Color(0xFFE91E63),
              icon: Icons.palette_outlined,
            ),
            const SizedBox(height: 12),
            const _ExploreCard(
              title: 'Sports Meet',
              subtitle: 'College Ground • 10 May 2026',
              accent: Color(0xFF558B2F),
              icon: Icons.emoji_events_outlined,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppTheme.fontBold,
                fontSize: 14,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;

  const _ExploreCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontBold,
                    fontSize: 15,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontRegular,
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Preview',
              style: TextStyle(
                fontFamily: AppTheme.fontBold,
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
