import 'package:flutter/material.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

/// Exactly 3 compulsory marketing slides — clean, light, #2563eb accents.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goLogin() => Navigator.of(context).pushReplacementNamed('/login');
  void _goSignup() => Navigator.of(context).pushNamed('/signup');

  void _next() {
    if (_index < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _goSignup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF6FF),
              AppColors.canvas,
              Color(0xFFF8FBFF),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.mBlueLight.withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.mBlueDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'US',
                              style: TextStyle(
                                fontFamily: AppTheme.fontBold,
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Uni',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontExtraBold,
                                  fontSize: 16,
                                  color: AppColors.onDark,
                                ),
                              ),
                              TextSpan(
                                text: 'Sphere',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontExtraBold,
                                  fontSize: 16,
                                  color: AppColors.mBlueDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _goLogin,
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              fontFamily: AppTheme.fontBold,
                              fontSize: 13,
                              color: AppColors.bodyStrong,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      onPageChanged: (i) => setState(() => _index = i),
                      children: [
                        _WelcomeSlide(onSignup: _goSignup, onLogin: _goLogin),
                        const _FeaturesSlide(),
                        _AboutSlide(onSignup: _goSignup),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
                    child: Row(
                      children: [
                        ...List.generate(3, (i) {
                          final active = _index == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 6),
                            height: 8,
                            width: active ? 22 : 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.mBlueDark
                                  : AppColors.mBlueDark.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                        const Spacer(),
                        if (_index < 2)
                          TextButton(
                            onPressed: _goSignup,
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                fontFamily: AppTheme.fontBold,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                        FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mBlueDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _index == 2 ? 'Get started' : 'Next',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontBold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
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

// ── Page 1: Welcome ──────────────────────────────────────────────────────────

class _WelcomeSlide extends StatelessWidget {
  final VoidCallback onSignup;
  final VoidCallback onLogin;

  const _WelcomeSlide({required this.onSignup, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.mBlueDark,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mBlueDark.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'US',
                style: TextStyle(
                  fontFamily: AppTheme.fontExtraBold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: AppTheme.fontExtraBold,
                fontSize: 40,
                height: 1.05,
                letterSpacing: -0.8,
                color: AppColors.onDark,
              ),
              children: [
                TextSpan(text: 'Uni'),
                TextSpan(
                  text: 'Sphere',
                  style: TextStyle(color: AppColors.mBlueDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Campus events,\nbeautifully simple.',
            style: TextStyle(
              fontFamily: AppTheme.fontBold,
              fontSize: 24,
              height: 1.2,
              color: AppColors.bodyStrong,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Discover what’s on, grab your pass, and walk in! Made for students.',
            style: TextStyle(
              fontFamily: AppTheme.fontRegular,
              fontSize: 15,
              height: 1.55,
              color: AppColors.body,
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onSignup,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mBlueDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Get started',
                style: TextStyle(fontFamily: AppTheme.fontBold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onLogin,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mBlueDark,
                side: const BorderSide(color: AppColors.mBlueDark, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Log in',
                style: TextStyle(fontFamily: AppTheme.fontBold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Page 2: Features ─────────────────────────────────────────────────────────

class _FeaturesSlide extends StatelessWidget {
  const _FeaturesSlide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What makes it special',
            style: TextStyle(
              fontFamily: AppTheme.fontExtraBold,
              fontSize: 28,
              height: 1.15,
              letterSpacing: -0.4,
              color: AppColors.onDark,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Three things UniSphere does really well.',
            style: TextStyle(
              fontFamily: AppTheme.fontRegular,
              fontSize: 15,
              color: AppColors.muted,
            ),
          ),
          const Spacer(),
          const _FeatureBlock(
            number: '01',
            title: 'Find the right events',
            body:
                'Inter-college fests or your own campus night:search without the noise.',
          ),
          const SizedBox(height: 28),
          const _FeatureBlock(
            number: '02',
            title: 'Your digital pass',
            body:
                'Register once. Carry a UNI pass in your QR Passport:no paper tickets.',
          ),
          const SizedBox(height: 28),
          const _FeatureBlock(
            number: '03',
            title: 'Fast QR check-in',
            body:
                'Show your UNI pass at the gate:no paper tickets, no long queues.',
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _FeatureBlock extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _FeatureBlock({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: TextStyle(
            fontFamily: AppTheme.fontExtraBold,
            fontSize: 16,
            color: AppColors.mBlueDark.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTheme.fontBold,
                  fontSize: 18,
                  color: AppColors.onDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: const TextStyle(
                  fontFamily: AppTheme.fontRegular,
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.body,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Page 3: How it works + About CTA ─────────────────────────────────────────

class _AboutSlide extends StatelessWidget {
  final VoidCallback onSignup;

  const _AboutSlide({required this.onSignup});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How it works',
            style: TextStyle(
              fontFamily: AppTheme.fontExtraBold,
              fontSize: 28,
              letterSpacing: -0.4,
              color: AppColors.onDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'From signup to the gate:three quiet steps.',
            style: TextStyle(
              fontFamily: AppTheme.fontRegular,
              fontSize: 15,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 28),
          const _FlowRow(
            title: 'Join',
            body: 'Create an account with your college.',
          ),
          const _FlowRow(
            title: 'Explore',
            body: 'Browse the feed and register in a tap.',
          ),
          const _FlowRow(
            title: 'Show up',
            body: 'Open your passport and check in at the door.',
            isLast: true,
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.mBlueDark,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your campus,\none sphere.',
                  style: TextStyle(
                    fontFamily: AppTheme.fontExtraBold,
                    fontSize: 24,
                    height: 1.15,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Whether you organize or attend — UniSphere keeps it running.',
                  style: TextStyle(
                    fontFamily: AppTheme.fontRegular,
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: onSignup,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.mBlueDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create account',
                      style: TextStyle(
                        fontFamily: AppTheme.fontBold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FlowRow extends StatelessWidget {
  final String title;
  final String body;
  final bool isLast;

  const _FlowRow({
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.mBlueDark,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 34,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: AppColors.mBlueLight.withValues(alpha: 0.5),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontBold,
                    fontSize: 16,
                    color: AppColors.onDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontRegular,
                    fontSize: 14,
                    color: AppColors.muted,
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
