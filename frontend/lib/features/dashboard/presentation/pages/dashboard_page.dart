import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/explore_screen.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/home_screen.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/my_events_screen.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/profile_screen.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    MyEventsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: DashboardPage._screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
