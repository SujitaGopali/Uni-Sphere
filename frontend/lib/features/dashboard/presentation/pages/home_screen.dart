import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;
    final name = user?.name.isNotEmpty == true ? user!.name : 'Student';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.menu_rounded, color: Colors.white, size: 26),
        ),
        title: Text(
          'Hi, $name 👋',
          style: const TextStyle(
            fontFamily: AppTheme.fontBold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child:
                Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(
                      fontFamily: AppTheme.fontBold,
                      fontSize: 18,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _EventCard(
                iconBg: Color(0xFFE8EAF6),
                icon: Icons.laptop_mac_outlined,
                iconColor: Color(0xFF5C6BC0),
                title: 'Tech Talk 2024',
                date: '2 May 2026, 10:00 AM',
                location: 'Seminar Hall',
              ),
              const SizedBox(height: 12),
              const _EventCard(
                iconBg: Color(0xFFFCE4EC),
                icon: Icons.music_note_rounded,
                iconColor: Color(0xFFE91E63),
                title: 'Cultural Fest',
                date: '6 May 2026, 5:00 PM',
                location: 'Open Auditorium',
              ),
              const SizedBox(height: 12),
              const _EventCard(
                iconBg: Color(0xFFF1F8E9),
                icon: Icons.sports_soccer_rounded,
                iconColor: Color(0xFF558B2F),
                title: 'Sports Meet',
                date: '10 May 2026, 9:00 AM',
                location: 'College Ground',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String date;
  final String location;

  const _EventCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 32),
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
                    const SizedBox(height: 5),
                    Text(
                      date,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontRegular,
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      location,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontRegular,
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.primary,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontBold,
                    fontSize: 13,
                  ),
                ),
                child: const Text('Preview'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
