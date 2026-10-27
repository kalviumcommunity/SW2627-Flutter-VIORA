import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/social_button.dart';
import '../core/firebase/firebase_manager.dart';
import 'location_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: 'sarah.kothari@gmail.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'secretpassword123');

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isNotEmpty && password.isNotEmpty) {
      await FirebaseManager().auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
    }
    if (!mounted) return;
    _navigateToNext();
  }

  void _onCreateAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isNotEmpty && password.isNotEmpty) {
      final rawName = email.split('@').first;
      final name = rawName.isNotEmpty
          ? '${rawName[0].toUpperCase()}${rawName.substring(1)}'
          : 'Member';
      await FirebaseManager().auth.createUserWithEmailAndPassword(
            name: name,
            email: email,
            password: password,
          );
    }
    if (!mounted) return;
    _navigateToNext();
  }

  void _onGoogleSignIn() async {
    await FirebaseManager().auth.signInWithGoogle();
    if (!mounted) return;
    _navigateToNext();
  }

  void _onAppleSignIn() async {
    await FirebaseManager().auth.signInWithApple();
    if (!mounted) return;
    _navigateToNext();
  }

  void _navigateToNext() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LocationPermissionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.textPrimary,
        content: Text(
          'Password reset link requested.',
          style: TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Optional back button if navigated from Onboarding
              Align(
                alignment: Alignment.centerLeft,
                child: Navigator.of(context).canPop()
                    ? GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
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
                      )
                    : const SizedBox(height: 38),
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
                'EXCLUSIVE SALON MEMBER ACCESS',
                textAlign: TextAlign.center,
                style: AppTextStyles.uppercaseSubtitle(
                  fontSize: 11.5,
                  letterSpacing: 2.4,
                ),
              ),

              const SizedBox(height: 44),

              // Email Address Field
              AppTextField(
                label: 'EMAIL ADDRESS',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'Enter your email',
              ),

              const SizedBox(height: 20),

              // Password Field
              AppTextField(
                label: 'PASSWORD',
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
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

              const SizedBox(height: 10),

              // Forgot Password link
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

              const SizedBox(height: 32),

              // Sign In Button
              AppButton(
                text: 'SIGN IN',
                onPressed: _onSignIn,
                variant: AppButtonVariant.primary,
              ),

              const SizedBox(height: 16),

              // Create Account Button
              AppButton(
                text: 'CREATE ACCOUNT',
                onPressed: _onCreateAccount,
                variant: AppButtonVariant.outlined,
              ),

              const SizedBox(height: 36),

              // Or continue with text
              Text(
                'Or continue with',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 22),

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
