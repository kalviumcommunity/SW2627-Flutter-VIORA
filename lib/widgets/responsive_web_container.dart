import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/firebase/firebase_manager.dart';

/// Wraps any screen in a responsive container optimized for Flutter Web & Desktop
class ResponsiveWebContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool showWebHeader;

  const ResponsiveWebContainer({
    super.key,
    required this.child,
    this.maxWidth = 480.0,
    this.showWebHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopWeb = kIsWeb && screenWidth > 640;

    if (!isDesktopWeb) {
      return child;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141312), // Deep luxury obsidian backdrop
      body: Center(
        child: Container(
          width: maxWidth,
          height: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 36,
                spreadRadius: 4,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: AppColors.gold.withOpacity(0.15),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (showWebHeader) _buildWebStatusBanner(context),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebStatusBanner(BuildContext context) {
    final user = FirebaseManager().auth.currentUser;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'V',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'VIORA WEB APP',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF2EC4B6), // Online indicator
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                user != null ? '${user.tierName} • ${user.name}' : 'Guest Session',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
