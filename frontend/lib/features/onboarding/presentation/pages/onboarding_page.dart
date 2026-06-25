import 'package:flutter/material.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<_OnboardingData> _screens = const [
    _OnboardingData(
      icon: Icons.calendar_month_rounded,
      title: 'Discover Events',
      description:
          'Find amazing campus events happening around you and never miss out on fun activities.',
    ),
    _OnboardingData(
      icon: Icons.people_alt_rounded,
      title: 'Connect with Friends',
      description:
          'Meet like-minded students and build meaningful connections through shared interests.',
    ),
    _OnboardingData(
      icon: Icons.schedule_rounded,
      title: 'Manage Your Schedule',
      description:
          'Keep track of events you\'re interested in and organize your campus life efficiently.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _screens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip Button ────────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: AppTheme.fontBold,
                      fontSize: 14,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),

            // ── Page View ──────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _screens.length,
                itemBuilder: (context, index) =>
                    _OnboardingSlide(data: _screens[index]),
              ),
            ),

            // ── Dots + Button ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _screens.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == i ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppTheme.primary
                              : AppTheme.primary.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _goToNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _currentPage == _screens.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontBold,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Onboarding Data Model ─────────────────────────────────────────────────────
class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ── Onboarding Slide ──────────────────────────────────────────────────────────
class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 80, color: AppTheme.primary),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: const TextStyle(
              fontFamily: AppTheme.fontExtraBold,
              fontSize: 26,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: const TextStyle(
              fontFamily: AppTheme.fontRegular,
              fontSize: 15,
              color: AppTheme.textMuted,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
