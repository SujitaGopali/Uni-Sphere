import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    // Defer provider updates until after the first frame (Riverpod rule).
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    // Never block splash on a slow/unreachable API — land on marketing quickly.
    try {
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 900)),
        ref.read(authViewModelProvider.notifier).restoreSession().timeout(
              const Duration(seconds: 3),
              onTimeout: () {},
            ),
      ]);
    } catch (_) {
      // Ignore restore failures; show landing/login.
    }
    if (!mounted) return;
    final user = ref.read(authViewModelProvider).user;
    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/landing');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.mBlueDark,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                    child: Text(
                      'US',
                      style: TextStyle(
                        fontFamily: AppTheme.fontExtraBold,
                        fontSize: 28,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Uni',
                        style: TextStyle(
                          fontFamily: AppTheme.fontExtraBold,
                          fontSize: 32,
                          color: AppColors.onDark,
                        ),
                      ),
                      TextSpan(
                        text: 'Sphere',
                        style: TextStyle(
                          fontFamily: AppTheme.fontExtraBold,
                          fontSize: 32,
                          color: AppColors.mBlueDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'College Event Management',
                  style: TextStyle(
                    fontFamily: AppTheme.fontRegular,
                    fontSize: 14,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.mBlueDark,
                    strokeWidth: 2.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
