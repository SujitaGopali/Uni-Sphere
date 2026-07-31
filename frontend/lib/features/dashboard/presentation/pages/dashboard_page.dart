import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/core/widgets/dash_widgets.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/discover_screen.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/events_ai_chat_screen.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/home_screen.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/my_events_screen.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/qr_passport_screen.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

final studentNavIndexProvider = StateProvider<int>((ref) => 0);

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  /// 0 Home, 1 Discover, 2 My Events, 3 Passport, 4 Profile
  static const _labels = [
    'Home',
    'Discover',
    'My Events',
    'Passport',
    'Profile',
  ];

  static const _icons = [
    Icons.home_outlined,
    Icons.search_rounded,
    Icons.favorite_border_rounded,
    Icons.qr_code_2_outlined,
    Icons.person_outline_rounded,
  ];

  static const _activeIcons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.favorite_rounded,
    Icons.qr_code_2,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(studentNavIndexProvider);

    final screens = [
      HomeScreen(
        onNavigate: (i) => ref.read(studentNavIndexProvider.notifier).state = i,
      ),
      const DiscoverScreen(),
      const MyEventsScreen(),
      const QrPassportScreen(),
      const ProfileScreen(),
    ];

    return Theme(
      data: AppTheme.dashboard,
      child: Scaffold(
        backgroundColor: AppColors.dashBg,
        body: DashboardBackground(
          child: IndexedStack(index: index, children: screens),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EventsAiChatScreen(),
                fullscreenDialog: true,
              ),
            );
          },
          backgroundColor: AppColors.dashAccent,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text(
            'Ask AI',
            style: TextStyle(fontFamily: AppTheme.fontBold),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.dashSidebar,
            border: Border(top: BorderSide(color: AppColors.dashBorder)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: List.generate(_labels.length, (i) {
                  final active = index == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(studentNavIndexProvider.notifier).state = i,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.dashAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              active ? _activeIcons[i] : _icons[i],
                              size: 20,
                              color:
                                  active ? Colors.black : AppColors.dashMuted,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: active
                                    ? AppTheme.fontBold
                                    : AppTheme.fontRegular,
                                fontSize: 9.5,
                                color: active
                                    ? Colors.black
                                    : AppColors.dashMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
