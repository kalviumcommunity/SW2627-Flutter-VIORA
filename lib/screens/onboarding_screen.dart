import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import 'sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<OnboardingSlideData> _slides = const [
    OnboardingSlideData(
      title: 'VIORA',
      subtitle: 'YOUR BEAUTY, PERFECTED',
      imageAsset: 'assets/images/salon_hero.png',
    ),
    OnboardingSlideData(
      title: 'VIORA',
      subtitle: 'ARTISAN STYLISTS & BESPOKE CARE',
      imageAsset: 'assets/images/salon_hero.png',
    ),
    OnboardingSlideData(
      title: 'VIORA',
      subtitle: 'EXCLUSIVE MEMBER REWARDS',
      imageAsset: 'assets/images/salon_hero.png',
    ),
  ];

  void _onGetStarted() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignInScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // Hero Image Section (takes ~58% of screen height)
              Expanded(
                flex: 58,
                child: SizedBox(
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        _slides[index].imageAsset,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          // Elegant fallback if asset path is resolving
                          return Container(
                            color: const Color(0xFF3D322B),
                            child: const Center(
                              child: Icon(
                                Icons.spa_outlined,
                                size: 64,
                                color: Color(0xFFC59265),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Bottom Content Section
              Expanded(
                flex: 42,
                child: Container(
                  width: double.infinity,
                  color: AppColors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(height: 8),

                        // Title & Subtitle
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _slides[_currentPage].title,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.brandTitle(
                                fontSize: 44,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _slides[_currentPage].subtitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.uppercaseSubtitle(
                                fontSize: 13,
                                letterSpacing: 2.8,
                              ),
                            ),
                          ],
                        ),

                        // Pagination Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_slides.length, (index) {
                            final isActive = index == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 8 : 7,
                              height: isActive ? 8 : 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.dotInactive,
                              ),
                            );
                          }),
                        ),

                        // Get Started CTA Button
                        AppButton(
                          text: 'GET STARTED',
                          onPressed: _onGetStarted,
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingSlideData {
  final String title;
  final String subtitle;
  final String imageAsset;

  const OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
  });
}
