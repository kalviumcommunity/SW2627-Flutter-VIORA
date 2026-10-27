import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/social_button.dart';
import '../core/firebase/firebase_manager.dart';
import '../services/api_client.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(text: 'sarah.kothari@gmail.com');
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(text: 'secretpassword123');

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    bool isValid = true;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUp) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        _nameError = 'Please enter your full name';
        isValid = false;
      }
    }

    if (email.isEmpty) {
      _emailError = 'Please enter your email address';
      isValid = false;
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _emailError = 'Please enter a valid email address';
        isValid = false;
      }
    }

    if (password.isEmpty) {
      _passwordError = 'Please enter your password';
      isValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
      _generalError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isSignUp) {
        final name = _nameController.text.trim();
        final phone = _phoneController.text.trim();
        await FirebaseManager().auth.createUserWithEmailAndPassword(
          name: name,
          email: email,
          password: password,
          phone: phone.isNotEmpty ? phone : null,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Welcome to VIORA Atelier.'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await FirebaseManager().auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;
      _navigateToNext();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _generalError = e.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFC62828),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      const msg = 'Connection failed. Please ensure the backend server is running and accessible.';
      setState(() {
        _generalError = msg;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(msg),
          backgroundColor: Color(0xFFC62828),
          duration: Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseManager().auth.signInWithGoogle();
      if (!mounted) return;
      _navigateToNext();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseManager().auth.signInWithApple();
      if (!mounted) return;
      _navigateToNext();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onContinueAsGuest() {
    FirebaseManager().auth.continueAsGuest();
    _navigateToNext();
  }

  void _navigateToNext() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.textPrimary,
        content: Text(
          'Password reset link requested. Please check your email.',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/onboarding');
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Brand Title
              Text(
                'VIORA',
                textAlign: TextAlign.center,
                style: AppTextStyles.brandTitle(
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),

              // Brand Subtitle
              Text(
                _isSignUp ? 'JOIN THE VIORA ATELIER' : 'EXCLUSIVE SALON MEMBER ACCESS',
                textAlign: TextAlign.center,
                style: AppTextStyles.uppercaseSubtitle(
                  fontSize: 11.5,
                  letterSpacing: 2.4,
                ),
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 24),

              // General error banner if present
              if (_generalError != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF5C6CB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFD9534F), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _generalError!,
                          style: const TextStyle(
                            color: Color(0xFF721C24),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Sign Up Name Field
              if (_isSignUp) ...[
                AppTextField(
                  label: 'FULL NAME',
                  controller: _nameController,
                  hintText: 'Enter your full name',
                  errorText: _nameError,
                ),
                const SizedBox(height: 16),
              ],

              // Email Address Field
              AppTextField(
                label: 'EMAIL ADDRESS',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'Enter your email',
                errorText: _emailError,
              ),

              if (_isSignUp) ...[
                const SizedBox(height: 16),
                AppTextField(
                  label: 'PHONE NUMBER (OPTIONAL)',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  hintText: '+91 98200 12345',
                ),
              ],

              const SizedBox(height: 16),

              // Password Field
              AppTextField(
                label: 'PASSWORD',
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                hintText: 'Minimum 6 characters',
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF6E6A65),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              if (!_isSignUp) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _onForgotPassword,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.linkText(underline: false).copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Main Action Buttons matching login-signup.png
              if (!_isSignUp) ...[
                AppButton(
                  text: 'SIGN IN',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                  variant: AppButtonVariant.primary,
                ),
                const SizedBox(height: 14),
                AppButton(
                  text: 'CREATE ACCOUNT',
                  onPressed: () {
                    setState(() {
                      _isSignUp = true;
                      _generalError = null;
                    });
                  },
                  variant: AppButtonVariant.outlined,
                ),
              ] else ...[
                AppButton(
                  text: 'CREATE ACCOUNT',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                  variant: AppButtonVariant.primary,
                ),
                const SizedBox(height: 14),
                AppButton(
                  text: 'ALREADY A MEMBER? SIGN IN',
                  onPressed: () {
                    setState(() {
                      _isSignUp = false;
                      _generalError = null;
                    });
                  },
                  variant: AppButtonVariant.outlined,
                ),
              ],

              const SizedBox(height: 16),

              // Guest Access Button
              GestureDetector(
                onTap: _onContinueAsGuest,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Continue as Guest',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Or continue with',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 18),

              // Social Sign-In buttons
              Row(
                children: [
                  SocialButton(
                    type: SocialType.google,
                    onPressed: _onGoogleSignIn,
                  ),
                  const SizedBox(width: 14),
                  SocialButton(
                    type: SocialType.apple,
                    onPressed: _onAppleSignIn,
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
