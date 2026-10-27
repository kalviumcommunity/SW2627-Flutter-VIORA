import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'service_subcategory_options_screen.dart';

class MakeupMenuItem {
  final String id;
  final String title;
  final String imageAsset;
  final int basePrice;

  const MakeupMenuItem({
    required this.id,
    required this.title,
    required this.imageAsset,
    required this.basePrice,
  });

  static const List<MakeupMenuItem> menuItems = [
    MakeupMenuItem(
      id: 'bridal_makeup',
      title: 'Bridal Makeup',
      imageAsset: 'assets/images/makeup_bridal.png',
      basePrice: 8500,
    ),
    MakeupMenuItem(
      id: 'engagement_makeup',
      title: 'Engagement Makeup',
      imageAsset: 'assets/images/makeup_engagement.png',
      basePrice: 5800,
    ),
    MakeupMenuItem(
      id: 'party_makeup',
      title: 'Party & Evening Makeup',
      imageAsset: 'assets/images/makeup_party.png',
      basePrice: 3800,
    ),
    MakeupMenuItem(
      id: 'hd_makeup',
      title: 'HD Makeup',
      imageAsset: 'assets/images/makeup_hd.png',
      basePrice: 4200,
    ),
    MakeupMenuItem(
      id: 'airbrush_makeup',
      title: 'Airbrush Makeup',
      imageAsset: 'assets/images/makeup_airbrush.png',
      basePrice: 5500,
    ),
    MakeupMenuItem(
      id: 'eye_makeup',
      title: 'Eye Makeup',
      imageAsset: 'assets/images/makeup_eye.png',
      basePrice: 1800,
    ),
    MakeupMenuItem(
      id: 'natural_makeup',
      title: 'Natural & Minimal Makeup',
      imageAsset: 'assets/images/makeup_minimal.png',
      basePrice: 2200,
    ),
  ];
}

class MakeupServicesScreen extends StatelessWidget {
  const MakeupServicesScreen({super.key});

  void _onSelectService(BuildContext context, MakeupMenuItem item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ServiceSubcategoryOptionsScreen(
          subcategoryId: item.id,
          subcategoryTitle: item.title,
          categoryTitle: 'Makeup',
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = MakeupMenuItem.menuItems;

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

              // Top Bar with Back Button and Centered Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed('/services');
                      }
                    },
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
                      'Makeup Services',
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

              // Section Heading
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
                'Select a service',
                style: AppTextStyles.editorialTitle(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              // 2-Column Grid (Level 2 proportions: 0.86 aspect ratio)
              GridView.builder(
                padding: const EdgeInsets.only(bottom: 32),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.86,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () => _onSelectService(context, item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.asset(
                              item.imageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(
                                  Icons.brush_outlined,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 10,
                            ),
                            color: AppColors.surface,
                            child: Text(
                              item.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
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
