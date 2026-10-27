import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Screen 1: VIORA Brand Onboarding & Introduction
/// Exact visual implementation of onboarding.png from design assets
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 1. Hero Image Section (Top ~55%)
          Expanded(
            flex: 55,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/salon_hero.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.spa, size: 64, color: AppColors.primary),
                  ),
                ),
                // Subtle bottom gradient fade into alabaster background
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.8),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Content & CTA Section (Bottom ~45%)
          Expanded(
            flex: 45,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Luxury Serif Brand Title
                    Text(
                      'VIORA',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.editorialTitle(
                        fontSize: 38,
                        fontWeight: FontWeight.w400,
                      ).copyWith(letterSpacing: 4.0),
                    ),
                    const SizedBox(height: 10),

                    // Brand Tagline
                    Text(
                      'YOUR BEAUTY, PERFECTED',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.uppercaseSubtitle(
                        fontSize: 12.5,
                        letterSpacing: 2.8,
                      ).copyWith(color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: 26),

                    // 3 Pagination Indicator Dots (Group 29.png / onboarding.png)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 3),

                    // Primary "GET STARTED" CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        child: const Text(
                          'GET STARTED',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
