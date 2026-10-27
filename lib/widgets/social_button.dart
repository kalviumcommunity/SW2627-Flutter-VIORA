import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

enum SocialType { google, apple }

class SocialButton extends StatelessWidget {
  final SocialType type;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isGoogle = type == SocialType.google;

    return Expanded(
      child: SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isGoogle)
                _buildGoogleIcon()
              else
                const Icon(
                  Icons.apple,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              const SizedBox(width: 8),
              Text(
                isGoogle ? 'Google' : 'Apple',
                style: AppTextStyles.socialButtonText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textPrimary, width: 1.6),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.close,
        size: 11,
        color: AppColors.textPrimary,
      ),
    );
  }
}
