import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/service_category.dart';
import 'nail_services_screen.dart';
import 'hair_services_screen.dart';
import 'skin_services_screen.dart';
import 'massage_services_screen.dart';
import 'hair_removal_services_screen.dart';
import 'mens_grooming_services_screen.dart';
import 'eyes_brows_services_screen.dart';
import 'makeup_services_screen.dart';
import 'subcategories_screen.dart';

class ServicesCategoriesScreen extends StatelessWidget {
  const ServicesCategoriesScreen({super.key});

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _handleCategoryTap(BuildContext context, ServiceCategory category) {
    switch (category.id) {
      case 'hair':
        _navigateToScreen(context, const HairServicesScreen());
        break;
      case 'skin':
        _navigateToScreen(context, const SkinServicesScreen());
        break;
      case 'nails':
        _navigateToScreen(context, const NailServicesScreen());
        break;
      case 'hair_removal':
      case 'threading':
      case 'waxing':
        _navigateToScreen(context, const HairRemovalServicesScreen());
        break;
      case 'eyes_brows':
        _navigateToScreen(context, const EyesBrowsServicesScreen());
        break;
      case 'massage':
      case 'body_care':
        _navigateToScreen(context, const MassageServicesScreen());
        break;
      case 'makeup':
        _navigateToScreen(context, const MakeupServicesScreen());
        break;
      case 'mens_grooming':
        _navigateToScreen(context, const MensGroomingServicesScreen());
        break;
      default:
        _navigateToScreen(
          context,
          SubcategoriesScreen(categoryTitle: category.name),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ServiceCategory.allCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Top Bar with back button and centered Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Services',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.editorialTitle(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 24),

              // Header: CURATED BEAUTY MENU & Select Category
              Text(
                'CURATED BEAUTY MENU',
                style: AppTextStyles.uppercaseSubtitle(
                  fontSize: 11,
                  letterSpacing: 2.2,
                ).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select Category',
                style: AppTextStyles.editorialTitle(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              // 3-Column Categories Grid with Smooth Scrolling
              GridView.builder(
                padding: const EdgeInsets.only(bottom: 32),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return GestureDetector(
                    onTap: () => _handleCategoryTap(context, cat),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 62,
                            child: SizedBox(
                              width: double.infinity,
                              child: Image.asset(
                                cat.imageAsset,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.primaryLight,
                                    child: const Icon(
                                      Icons.spa_outlined,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 38,
                            child: Container(
                              width: double.infinity,
                              color: AppColors.surface,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              alignment: Alignment.center,
                              child: Text(
                                cat.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
