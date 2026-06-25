import 'package:flutter/material.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _interestedEvents = [
    {
      'iconBg': const Color(0xFFE8EAF6),
      'icon': Icons.laptop_mac_outlined,
      'iconColor': const Color(0xFF5C6BC0),
      'title': 'Tech Talk 2024',
      'date': '2 May 2026, 10:00 AM',
      'location': 'Seminar Hall',
    },
    {
      'iconBg': const Color(0xFFFCE4EC),
      'icon': Icons.music_note_rounded,
      'iconColor': const Color(0xFFE91E63),
      'title': 'Cultural Fest',
      'date': '6 May 2026, 5:00 PM',
      'location': 'Open Auditorium',
    },
    {
      'iconBg': const Color(0xFFF1F8E9),
      'icon': Icons.sports_soccer_rounded,
      'iconColor': const Color(0xFF558B2F),
      'title': 'Sports Meet',
      'date': '10 May 2026, 9:00 AM',
      'location': 'College Ground',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          'My Events',
          style: TextStyle(
            fontFamily: AppTheme.fontBold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            color: Colors.white,
            child: IgnorePointer(
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primary,
                unselectedLabelColor: const Color(0xFF9E9E9E),
                labelStyle: const TextStyle(
                  fontFamily: AppTheme.fontBold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: AppTheme.fontRegular,
                  fontSize: 14,
                ),
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Interested'),
                  Tab(text: 'Attended'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _interestedEvents.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final e = _interestedEvents[i];
              return _MyEventTile(
                iconBg: e['iconBg'] as Color,
                icon: e['icon'] as IconData,
                iconColor: e['iconColor'] as Color,
                title: e['title'] as String,
                date: e['date'] as String,
                location: e['location'] as String,
              );
            },
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 64,
                  color: Color(0xFFBDBDBD),
                ),
                SizedBox(height: 16),
                Text(
                  'No attended events yet',
                  style: TextStyle(
                    fontFamily: AppTheme.fontBold,
                    fontSize: 16,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyEventTile extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String date;
  final String location;

  const _MyEventTile({
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
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
    );
  }
}
