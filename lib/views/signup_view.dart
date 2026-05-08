import 'package:flutter/material.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers matching your project structure
  final _fnameCtrl = TextEditingController();
  final _lnameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  
  String? _gender;
  bool _obscure = true;

  // Gender options from your original implementation
  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _fnameCtrl.dispose();
    _lnameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState?.validate() ?? false) {
      // Show success feedback matching your original logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created. Please login.'),
          backgroundColor: Color(0xFF0052D4),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Defining the custom blue color locally for consistency
    const primaryBlue = Color(0xFF0052D4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Student Account'),
        foregroundColor: Colors.white,
        backgroundColor: primaryBlue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join UniSphere',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your details to register for campus events.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                
                // First Name Field
                TextFormField(
                  controller: _fnameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline, color: primaryBlue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter first name'
                      : null,
                ),
                const SizedBox(height: 16),
                
                // Last Name Field
                TextFormField(
                  controller: _lnameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline, color: primaryBlue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter last name'
                      : null,
                ),
                const SizedBox(height: 16),
                
                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc_rounded, color: primaryBlue),
                    border: OutlineInputBorder(),
                  ),
                  items: _genders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _gender = v),
                  validator: (v) => v == null ? 'Please select gender' : null,
                ),
                const SizedBox(height: 16),
                
                // Username Field
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.account_circle, color: primaryBlue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter username'
                      : null,
                ),
                const SizedBox(height: 16),
                
                // Email Field with Regex Validation
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: primaryBlue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter email';
                    }
                    final ok = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(v.trim());
                    return ok ? null : 'Please enter a valid email';
                  },
                ),
                const SizedBox(height: 16),
                
                // Password Field with Visibility Toggle
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: primaryBlue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                        color: primaryBlue,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter password';
                    if (v.length < 6) return 'Password must be 6+ characters';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Submit Button
                FilledButton(
                  onPressed: _signup,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Back to Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}