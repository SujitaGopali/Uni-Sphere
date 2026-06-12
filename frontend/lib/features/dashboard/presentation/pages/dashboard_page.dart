import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/explore_screen.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/home_screen.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/my_events_screen.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:uni_sphere/themes/app_theme.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    MyEventsScreen(),
    ProfileScreen(),
  ];

  static const List<String> _titles = [
    'Hi, Student 👋',
    'Explore',
    'My Events',
    'Profile',
  ];

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Future<void> _handleLogout() async {
    final user = ref.read(authViewModelProvider).user;
    if (user == null) return;

    await ref.read(authViewModelProvider.notifier).logout(user.email);

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navIndexProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          DashboardPage._titles[currentIndex],
          style: const TextStyle(fontFamily: AppTheme.fontBold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: DashboardPage._screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => ref.read(navIndexProvider.notifier).state = i,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'My Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
