import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'service_details_screen.dart';

class SubcategoryItem {
  final String title;
  final String imageAsset;
  final int price;
  final int durationMinutes;
  final String description;

  const SubcategoryItem({
    required this.title,
    required this.imageAsset,
    required this.price,
    required this.durationMinutes,
    required this.description,
  });
}

class SubcategoriesScreen extends StatelessWidget {
  final String categoryTitle;
  final String curatedMenuSubtitle;
  final List<SubcategoryItem>? items;

  const SubcategoriesScreen({
    super.key,
    this.categoryTitle = 'Makeup Services',
    this.curatedMenuSubtitle = 'CURATED BEAUTY MENU',
    this.items,
  });

  static const List<SubcategoryItem> defaultMakeupItems = [
    SubcategoryItem(
      title: 'Bridal Glam Makeup',
      imageAsset: 'assets/images/service_makeup.png',
      price: 6500,
      durationMinutes: 90,
      description:
          'High-definition bridal makeup with premium airbrush finish, individual mink lash placement, and waterproof veil seal.',
    ),
    SubcategoryItem(
      title: 'Red Carpet Evening Glam',
      imageAsset: 'assets/images/service_brows.png',
      price: 3800,
      durationMinutes: 60,
      description:
          'Signature luminous contouring, dramatic winged eye artistry, and customized luxury nude or statement lip.',
    ),
    SubcategoryItem(
      title: 'Soft Editorial Glow',
      imageAsset: 'assets/images/skin_facials.png',
      price: 2800,
      durationMinutes: 45,
      description:
          'Dewy, glass-skin aesthetic focusing on enhanced natural features, feather brows, and hydrating lip glaze.',
    ),
    SubcategoryItem(
      title: 'Lash & Brow Accentuation',
      imageAsset: 'assets/images/removal_threading.png',
      price: 1800,
      durationMinutes: 40,
      description:
          'Custom lash lifting paired with botanical brow lamination and defining henna infusion.',
    ),
  ];

  static List<SubcategoryItem> getItemsForCategory(String categoryKey) {
    final key = categoryKey.toLowerCase();
    if (key.contains('hair') && !key.contains('removal')) {
      return const [
        SubcategoryItem(
          title: 'Signature Cut & Blow Dry',
          imageAsset: 'assets/images/hair_cut_styling.png',
          price: 2400,
          durationMinutes: 75,
          description:
              'Experience bespoke precision cutting tailored to your facial contours and texture, finished with a luminous blow-dry styling.',
        ),
        SubcategoryItem(
          title: 'Balayage & Gloss Tonality',
          imageAsset: 'assets/images/hair_colour.png',
          price: 4200,
          durationMinutes: 120,
          description:
              'Artisanal hand-painted sun-kissed gradients blended with customizable gloss glaze for unmatched radiance.',
        ),
        SubcategoryItem(
          title: 'Deep Nourishing Hair Spa',
          imageAsset: 'assets/images/hair_spa_care.png',
          price: 2200,
          durationMinutes: 60,
          description:
              'Intense botanical moisture infusion, hot towel steam therapy, and rejuvenating scalp pressure-point massage.',
        ),
        SubcategoryItem(
          title: 'Keratin Restorative Therapy',
          imageAsset: 'assets/images/hair_smoothening.png',
          price: 4800,
          durationMinutes: 90,
          description:
              'Formaldehyde-free smoothing system restoring internal protein matrix with 12-week anti-frizz defense.',
        ),
      ];
    } else if (key.contains('skin')) {
      return const [
        SubcategoryItem(
          title: 'Cellular Hydration Facial',
          imageAsset: 'assets/images/skin_facials.png',
          price: 2800,
          durationMinutes: 60,
          description:
              'Multi-molecular hyaluronic acid infusion and lymphatic drainage for deeply quenched, luminous skin.',
        ),
        SubcategoryItem(
          title: 'Clarifying Deep Cleanse',
          imageAsset: 'assets/images/skin_cleanse_detox.png',
          price: 2200,
          durationMinutes: 45,
          description:
              'Ultrasonic pore extraction, botanical purifying mask, and soothing cryo-globe finish.',
        ),
        SubcategoryItem(
          title: 'Radiance AHA/BHA Peel',
          imageAsset: 'assets/images/skin_peels.png',
          price: 3400,
          durationMinutes: 50,
          description:
              'Gentle dermatological resurfacing revealing refined texture, reduced hyperpigmentation, and instant glow.',
        ),
        SubcategoryItem(
          title: 'Anti-Aging Botanical Ritual',
          imageAsset: 'assets/images/skin_spa_rituals.png',
          price: 4500,
          durationMinutes: 75,
          description:
              'Collagen-stimulating peptides, micro-current contour lifting, and 24k gold leaf serum shield.',
        ),
      ];
    } else if (key.contains('nail')) {
      return const [
        SubcategoryItem(
          title: 'Gel Polish Manicure',
          imageAsset: 'assets/images/service_nails.png',
          price: 1400,
          durationMinutes: 45,
          description:
              'Impeccable Russian cuticle contouring, strengthening base, and high-shine LED gel finish.',
        ),
        SubcategoryItem(
          title: 'Brown Ombre Cat Eye Nails',
          imageAsset: 'assets/images/nail_brown_cat_eye.png',
          price: 2600,
          durationMinutes: 60,
          description:
              'Velvet magnetic reflection with customized warm mocha undertones and high-gloss top seal.',
        ),
        SubcategoryItem(
          title: 'Luxury Spa Pedicure',
          imageAsset: 'assets/images/service_pedicure.png',
          price: 2200,
          durationMinutes: 60,
          description:
              'Dead Sea mineral salt soak, glycolic callus smoothing, hot stone leg massage, and flawless polish.',
        ),
        SubcategoryItem(
          title: 'Acrylic Gel Full Extension',
          imageAsset: 'assets/images/service_nail_art.png',
          price: 3600,
          durationMinutes: 75,
          description:
              'Sculpted lightweight extensions tailored to your desired length and silhouette with nail bed protection.',
        ),
      ];
    } else if (key.contains('thread')) {
      return const [
        SubcategoryItem(
          title: 'Eyebrow Shaping & Sculpt',
          imageAsset: 'assets/images/removal_threading.png',
          price: 250,
          durationMinutes: 20,
          description:
              'Antibacterial organic thread precision sculpting tailored to your natural brow architecture.',
        ),
        SubcategoryItem(
          title: 'Upper Lip & Chin Contouring',
          imageAsset: 'assets/images/removal_chin.png',
          price: 250,
          durationMinutes: 15,
          description:
              'Gentle, swift removal with organic thread followed by calming rosewater mist and aloe cooling gel.',
        ),
        SubcategoryItem(
          title: 'Full Facial Threading',
          imageAsset: 'assets/images/removal_threading.png',
          price: 750,
          durationMinutes: 35,
          description:
              'Complete facial grooming including forehead, sides, upper lip, chin, and eyebrow finishing.',
        ),
        SubcategoryItem(
          title: 'Forehead & Neck Detailing',
          imageAsset: 'assets/images/removal_threading.png',
          price: 350,
          durationMinutes: 20,
          description:
              'Crisp hairline definition and neck cleanup with soothing chamomile post-treatment balm.',
        ),
      ];
    } else if (key.contains('wax')) {
      return const [
        SubcategoryItem(
          title: 'Full Body Luxury Waxing',
          imageAsset: 'assets/images/removal_waxing.png',
          price: 2800,
          durationMinutes: 60,
          description:
              'Premium hypoallergenic strip and hard wax enriched with titanium dioxide for sensitive skin comfort.',
        ),
        SubcategoryItem(
          title: 'Brazilian Bikini Ritual',
          imageAsset: 'assets/images/removal_waxing.png',
          price: 1600,
          durationMinutes: 35,
          description:
              'Gentle low-temperature stripless wax with soothing azulene oil and ingrown hair prevention treatment.',
        ),
        SubcategoryItem(
          title: 'Full Arms & Underarms',
          imageAsset: 'assets/images/removal_waxing.png',
          price: 950,
          durationMinutes: 30,
          description:
              'Silky smooth arm care with pre-wax botanical cleanse and post-wax tea tree calming lotion.',
        ),
        SubcategoryItem(
          title: 'Full Legs Silky Waxing',
          imageAsset: 'assets/images/removal_waxing.png',
          price: 1200,
          durationMinutes: 35,
          description:
              'Exfoliating dry brush prep followed by golden honey wax and cooling cucumber hydration veil.',
        ),
      ];
    } else if (key.contains('eye') || key.contains('brow')) {
      return const [
        SubcategoryItem(
          title: 'Microblading Feather Touch',
          imageAsset: 'assets/images/service_brows.png',
          price: 4500,
          durationMinutes: 75,
          description:
              'Semi-permanent ultra-fine hair strokes simulating natural brow fullness with custom pigment matching.',
        ),
        SubcategoryItem(
          title: 'Brow Lamination & Keratin',
          imageAsset: 'assets/images/removal_threading.png',
          price: 1800,
          durationMinutes: 45,
          description:
              'Restructures brow hairs into a fuller, fluffy, brushed-up finish lasting up to 8 weeks.',
        ),
        SubcategoryItem(
          title: 'Lash Lift & Henna Glaze',
          imageAsset: 'assets/images/service_brows.png',
          price: 2200,
          durationMinutes: 45,
          description:
              'Natural lash curl lift from root with nourishing vegan keratin and deep obsidian tinting.',
        ),
        SubcategoryItem(
          title: 'HD Brows Precision Sculpt',
          imageAsset: 'assets/images/service_brows.png',
          price: 950,
          durationMinutes: 30,
          description:
              'Custom tint blending, mapping, waxing, threading, and styling for iconic defined brows.',
        ),
      ];
    } else if (key.contains('body') || key.contains('massage')) {
      return const [
        SubcategoryItem(
          title: 'Swedish Full Body Massage',
          imageAsset: 'assets/images/massage_full_body.png',
          price: 3200,
          durationMinutes: 60,
          description:
              'Gentle long gliding strokes and rhythmic tapping to relieve tension, boost circulation, and calm the mind.',
        ),
        SubcategoryItem(
          title: 'Deep Tissue Muscle Ritual',
          imageAsset: 'assets/images/massage_upper_body.png',
          price: 3800,
          durationMinutes: 75,
          description:
              'Targeted firm pressure releasing chronic muscle knots, myofascial tightness, and postural strain.',
        ),
        SubcategoryItem(
          title: 'Aroma Healing Relaxology',
          imageAsset: 'assets/images/service_massage.png',
          price: 2900,
          durationMinutes: 60,
          description:
              'Cold-pressed French lavender and sandalwood essential oils combined with Swedish soothing technique.',
        ),
        SubcategoryItem(
          title: 'Scalp Detox & Head Massage',
          imageAsset: 'assets/images/massage_head_scalp.png',
          price: 1800,
          durationMinutes: 40,
          description:
              'Warm Ayurvedic herbal oil infusion with intensive acupressure stimulation to revitalize hair follicles.',
        ),
      ];
    } else if (key.contains('men') || key.contains('groom')) {
      return const [
        SubcategoryItem(
          title: 'Executive Haircut & Styling',
          imageAsset: 'assets/images/grooming_shave.png',
          price: 1200,
          durationMinutes: 40,
          description:
              'Consultation, tailored scissor and fade craftsmanship, scalp scrub cleanse, and matte clay styling.',
        ),
        SubcategoryItem(
          title: 'Royal Shave & Beard Sculpt',
          imageAsset: 'assets/images/grooming_beard_styling.png',
          price: 850,
          durationMinutes: 30,
          description:
              'Hot towel pre-treatment, straight razor precision edging, cold towel closure, and nourishing beard oil.',
        ),
        SubcategoryItem(
          title: "Men's Charcoal Detox Facial",
          imageAsset: 'assets/images/service_grooming.png',
          price: 1800,
          durationMinutes: 45,
          description:
              'Deep cleansing targeting congested pores, ingrown hair relief, and cooling antioxidant moisture shield.',
        ),
        SubcategoryItem(
          title: "Men's Signature Package",
          imageAsset: 'assets/images/grooming_beard_moustache.png',
          price: 2800,
          durationMinutes: 75,
          description:
              'Haircut, beard sculpt, head massage, and rapid refreshing skin facial for the ultimate executive refresh.',
        ),
      ];
    } else {
      return defaultMakeupItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = items ?? getItemsForCategory(categoryTitle);

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

              // Top Bar with Back Button and Title
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
                      categoryTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.editorialTitle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 28),

              // Header Titles
              Text(
                curatedMenuSubtitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a service',
                style: AppTextStyles.editorialTitle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              // 2-Column Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.82,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ServiceDetailsScreen(
                            title: item.title,
                            category: categoryTitle,
                            price: item.price,
                            durationMinutes: item.durationMinutes,
                            description: item.description,
                            imageAsset: item.imageAsset,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration:
                              const Duration(milliseconds: 300),
                        ),
                      );
                    },
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
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1:1 Aspect Ratio Image
                          Expanded(
                            child: Image.asset(
                              item.imageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFF3ECE6),
                                  child: const Center(
                                    child: Icon(
                                      Icons.spa_outlined,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Service Title and Price
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${item.price} • ${item.durationMinutes}m',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
