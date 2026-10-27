import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/location_badge.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Top Bar with back button to Sign In & "Welcome"
                      Row(
                        children: [
                          if (Navigator.of(context).canPop())
                            GestureDetector(
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
                          else
                            const SizedBox(width: 38),
                          Expanded(
                            child: Text(
                              'Welcome',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.editorialTitle(
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 38),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Location Badge with subtle concentric rings
                      const LocationBadge(size: 200),

                      const SizedBox(height: 28),

                      // Main Section: "Find Your Nearest Salon" & description
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Find Your Nearest Salon',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.editorialTitle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              'To provide you with seamless booking, accurate branch distances, and stylist availability, please allow access to your device location.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyText,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppButton(
                            text: 'ALLOW LOCATION ACCESS',
                            onPressed: () => _navigateToHome(context),
                          ),
                          const SizedBox(height: 18),
                          GestureDetector(
                            onTap: () => _navigateToHome(context),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                'Enter Location Manually',
                                style: AppTextStyles.linkText(underline: true),
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
          },
        ),
      ),
    );
  }
}
