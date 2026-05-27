import 'package:flutter/material.dart';
import 'package:uni_sphere/screens/dashboard_screen.dart';
import 'package:uni_sphere/views/signup_view.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // The primary purple-blue color from your Figma design
  static const Color uniBlue = Color(0xFF6259E8);

  // Helper widget to construct the boxed text fields with icons
  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    bool isPassword = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.black38, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              obscureText: isPassword,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.black38),
                border: InputBorder.none,
              ),
            ),
          ),
          if (isPassword)
            const Icon(Icons.visibility_off_outlined, color: Colors.black38),
        ],
      ),
    );
  }

  // Pure Flutter illustration to replace the missing image asset
  Widget _buildFigmaIllustration() {
    return Center(
      child: SizedBox(
        height: 160,
        width: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background decorative soft purple circle
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: uniBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
            
            // The Mobile Phone Frame
            Positioned(
              right: 35,
              bottom: 10,
              child: Container(
                width: 70,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: uniBlue, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: uniBlue.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Top speaker line
                    Container(
                      width: 18,
                      height: 3,
                      decoration: BoxDecoration(
                        color: uniBlue.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Spacer(),
                    // Blue lock icon inside the phone screen
                    Icon(Icons.lock_rounded, size: 26, color: uniBlue.withValues(alpha: 0.85)),
                    const Spacer(),
                    // Home button line
                    Container(
                      width: 25,
                      height: 3,
                      decoration: BoxDecoration(
                        color: uniBlue.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                  ],
                ),
              ),
            ),

            // Character Standing on Left (Built with Avatars and Containers)
            Positioned(
              left: 25,
              bottom: 15,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: uniBlue.withValues(alpha: 0.15),
                      child: const Icon(Icons.person_rounded, size: 36, color: uniBlue),
                    ),
                  ),
                  // Small shield indicator representing secure login
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Floating decorative key near the phone
            Positioned(
              top: 25,
              right: 25,
              child: Transform.rotate(
                angle: -0.5,
                child: Icon(
                  Icons.vpn_key_rounded,
                  color: uniBlue.withValues(alpha: 0.6),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // 1. Centered Header Text
              const Text(
                'Welcome Back!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 24),

              // 2. Pure Code Figma Illustration
              _buildFigmaIllustration(),
              const SizedBox(height: 32),

              // 3. Email Input Box
              _buildTextField(
                icon: Icons.email_outlined,
                hintText: 'Email',
              ),
              const SizedBox(height: 16),

              // 4. Password Input Box
              _buildTextField(
                icon: Icons.lock_outlined,
                hintText: 'Password',
                isPassword: true,
              ),

              // 5. Forgot Password Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: uniBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 6. Full-Width Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardView()),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: uniBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 7. Navigation link to Signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupView()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: uniBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}