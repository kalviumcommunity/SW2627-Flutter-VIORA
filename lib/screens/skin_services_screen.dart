import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'service_subcategory_options_screen.dart';

class SkinServiceMenuItem {
  final String id;
  final String title;
  final String imageAsset;
  final int basePrice;

  const SkinServiceMenuItem({
    required this.id,
    required this.title,
    required this.imageAsset,
    required this.basePrice,
  });

  static const List<SkinServiceMenuItem> menuItems = [
    SkinServiceMenuItem(
      id: 'facials',
      title: 'Facials',
      imageAsset: 'assets/images/skin_facials.png',
      basePrice: 2200,
    ),
    SkinServiceMenuItem(
      id: 'skin_cleanse_detox',
      title: 'Skin Cleanse & Detox',
      imageAsset: 'assets/images/skin_cleanse_detox.png',
      basePrice: 1800,
    ),
    SkinServiceMenuItem(
      id: 'skin_concerns',
      title: 'Skin Concerns & Corrective Care',
      imageAsset: 'assets/images/skin_concerns.png',
      basePrice: 2800,
    ),
    SkinServiceMenuItem(
      id: 'peels_exfoliation',
      title: 'Peels & Exfoliation',
      imageAsset: 'assets/images/skin_peels.png',
      basePrice: 2500,
    ),
    SkinServiceMenuItem(
      id: 'advanced_therapy',
      title: 'Advanced Technology & Therapy',
      imageAsset: 'assets/images/skin_advanced_therapy.png',
      basePrice: 3500,
    ),
    SkinServiceMenuItem(
      id: 'body_care',
      title: 'Body Care',
      imageAsset: 'assets/images/skin_body_care.png',
      basePrice: 3000,
    ),
    SkinServiceMenuItem(
      id: 'spa_rituals',
      title: 'Spa & Rituals',
      imageAsset: 'assets/images/skin_spa_rituals.png',
      basePrice: 3800,
    ),
  ];
}

class SkinServicesScreen extends StatelessWidget {
  const SkinServicesScreen({super.key});

  void _onSelectService(BuildContext context, SkinServiceMenuItem item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ServiceSubcategoryOptionsScreen(
          subcategoryId: item.id,
          subcategoryTitle: item.title,
          categoryTitle: 'Skin',
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
    final items = SkinServiceMenuItem.menuItems;

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

              // Top Bar with Back Button and Centered "Skin Services" Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed('/home');
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
                      'Skin Services',
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

              // 7 Services Grid with Smooth Scrolling
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
                                  Icons.spa_outlined,
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
                            alignment: Alignment.center,
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
                                height: 1.2,
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
