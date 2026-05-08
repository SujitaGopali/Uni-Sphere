import 'package:flutter/material.dart';
import 'package:uni_sphere/views/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int _index = 0;
  static const Color uniBlue = Color(0xFF4A55A2);

  // Requirement: 3 Distinct Screens that are NOT the Splash logo
  final List<_OnboardingPage> _pages = [
    const _OnboardingPage(
      icon: Icons.calendar_today_rounded, // New Icon: Calendar/Schedule
      title: 'Discover Events',
      description: 'Explore all upcoming workshops, fests, and seminars at your campus.',
    ),
    const _OnboardingPage(
      icon: Icons.qr_code_2_rounded, // New Icon: QR/Tickets
      title: 'Instant Booking',
      description: 'Get your entry passes instantly by registering through the app.',
    ),
    const _OnboardingPage(
      icon: Icons.people_alt_rounded, // New Icon: Community/Students
      title: 'Connect with Peers',
      description: 'Join event groups and interact with students who share your interests.',
    ),
  ];

  void _next() {
    if (_index == _pages.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _dot(int i) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _index == i ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _index == i ? uniBlue : uniBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (_) => const LoginView())
                ),
                child: const Text('Skip', style: TextStyle(color: Colors.black54)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Different iconography for each step
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: uniBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_pages[i].icon, size: 100, color: uniBlue),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _pages[i].title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: uniBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pages[i].description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16, 
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Progress indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => _dot(i)),
            ),
            const SizedBox(height: 40),
            // Action button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: uniBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  onPressed: _next,
                  child: Text(
                    _index == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}