import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/core/constants/colleges.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _college;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.mRed,
        ),
      );
      return;
    }
    if (_college == null || _college!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your college'),
          backgroundColor: AppColors.mRed,
        ),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.mRed,
        ),
      );
      return;
    }

    final parts = _nameController.text.trim().split(RegExp(r'\s+'));
    final first = parts.first;
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : 'User';

    final entity = AuthEntity(
      firstName: first,
      lastName: last,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: 'user',
      college: _college,
    );

    ref.read(authViewModelProvider.notifier).register(entity);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.isSuccess && next.error == null && previous?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please sign in.'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        ref.read(authViewModelProvider.notifier).clearAuth();
        Navigator.pushReplacementNamed(context, '/login');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.mRed,
          ),
        );
        ref.read(authViewModelProvider.notifier).resetState();
      }
    });

    final isLoading = ref.watch(authViewModelProvider).isLoading;
    final colleges = getCollegeOptions();

    return Scaffold(
      backgroundColor: AppColors.surfaceCard,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  color: AppColors.onDark,
                ),
              ),
              const Text(
                'Create account',
                style: TextStyle(
                  fontFamily: AppTheme.fontExtraBold,
                  fontSize: 28,
                  color: AppColors.onDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Join UniSphere today',
                style: TextStyle(
                  fontFamily: AppTheme.fontRegular,
                  fontSize: 14,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.hairline),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.carbon.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('Full Name*'),
                    _field(
                      controller: _nameController,
                      hint: 'Ram Lal',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    _label('Email Address*'),
                    _field(
                      controller: _emailController,
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _label('College / University*'),
                    DropdownButtonFormField<String>(
                      initialValue: _college,
                      isExpanded: true,
                      decoration: _decoration(Icons.apartment_outlined),
                      hint: const Text(
                        'Select college',
                        style: TextStyle(color: AppColors.carbon, fontSize: 14),
                      ),
                      items: colleges
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.onDark,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _college = v),
                    ),
                    const SizedBox(height: 14),
                    _label('Password*'),
                    _field(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.muted,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _label('Confirm Password*'),
                    _field(
                      controller: _confirmPasswordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.muted,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: isLoading ? null : _handleSignup,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.mBlueDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : const Text(
                                'Create account',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontBold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontFamily: AppTheme.fontRegular,
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: AppTheme.fontBold,
                        fontSize: 14,
                        color: AppColors.mBlueDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: AppTheme.fontBold,
            fontSize: 12,
            color: AppColors.bodyStrong,
          ),
        ),
      );

  InputDecoration _decoration(IconData icon) => InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.muted, size: 20),
        filled: true,
        fillColor: AppColors.surfaceElevated.withValues(alpha: 0.45),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.mBlueLight, width: 1.5),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: AppTheme.fontRegular,
        fontSize: 15,
        color: AppColors.onDark,
      ),
      decoration: _decoration(icon).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.carbon, fontSize: 14),
        suffixIcon: suffix,
      ),
    );
  }
}
