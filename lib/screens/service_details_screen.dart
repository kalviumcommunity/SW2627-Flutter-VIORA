import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import 'branches_list_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final String? serviceName;
  final String? servicePrice;
  final String? serviceDuration;
  final String? serviceDescription;

  const ServiceDetailsScreen({
    super.key,
    this.serviceName,
    this.servicePrice,
    this.serviceDuration,
    this.serviceDescription,
  });

  @override
  Widget build(BuildContext context) {
    // Check if arguments were passed via ModalRoute
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final name = serviceName ?? args?['serviceName'] ?? 'Signature Haute Coiffure';
    final price = servicePrice ?? args?['servicePrice'] ?? '\$140';
    final duration = serviceDuration ?? args?['serviceDuration'] ?? '60 mins';
    final description = serviceDescription ??
        args?['serviceDescription'] ??
        'A comprehensive luxury consultation followed by precision styling, bespoke conditioning, and a sensory blow-dry finish tailored precisely to your silhouette.';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'SERVICE DETAILS',
          style: AppTextStyles.labelStyle.copyWith(
            fontSize: 13,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxDecoration(
                    color: AppColors.bronze.withAlpha(8),
                    borderRadius: BorderRadius.circular(16),
                  ).boxShadow?.first ??
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.bronze.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.bronze.withAlpha(60)),
                        ),
                        child: Text(
                          price,
                          style: AppTextStyles.priceStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.bronze,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        duration,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.workspace_premium_outlined, size: 16, color: AppColors.bronze),
                      const SizedBox(width: 6),
                      Text(
                        'Master Stylist',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.bronze,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppColors.cardBorder, height: 1),
                  ),
                  Text(
                    'THE EXPERIENCE',
                    style: AppTextStyles.labelStyle.copyWith(
                      letterSpacing: 1.5,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Luxury inclusions
            Text(
              'INCLUDED IN YOUR SESSION',
              style: AppTextStyles.labelStyle.copyWith(
                letterSpacing: 1.5,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInclusionItem(
              icon: Icons.spa_outlined,
              title: 'Artisanal Consultation',
              description: 'Personalized diagnostic of texture, facial contour, and preference.',
            ),
            _buildInclusionItem(
              icon: Icons.local_drink_outlined,
              title: 'Signature Refreshment Bar',
              description: 'Complimentary reserve espresso, infused botanical waters, or champagne.',
            ),
            _buildInclusionItem(
              icon: Icons.auto_awesome_outlined,
              title: 'Sensory Scalp Ritual',
              description: 'Gentle acupressure treatment with rare plant botanicals.',
            ),
            const SizedBox(height: 32),
            // Select Branch Button
            AppButton(
              text: 'SELECT SALON BRANCH',
              onPressed: () {
                final cleanedPrice = int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 140;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BranchesListScreen(
                      selectedServiceTitle: name,
                      selectedPrice: cleanedPrice,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInclusionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bronze.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.bronze),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
