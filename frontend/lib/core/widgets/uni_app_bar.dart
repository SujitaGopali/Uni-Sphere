import 'package:flutter/material.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class UniAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showHamburger;

  const UniAppBar({super.key, required this.title, this.showHamburger = false});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primary,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (showHamburger) ...[
            const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 12),
          ],
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.fontBold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {},
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
