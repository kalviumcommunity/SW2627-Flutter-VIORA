import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/nail_service.dart';
import 'nail_detail_screen.dart';

class NailArtServicesScreen extends StatefulWidget {
  const NailArtServicesScreen({super.key});

  @override
  State<NailArtServicesScreen> createState() => _NailArtServicesScreenState();
}

class _NailArtServicesScreenState extends State<NailArtServicesScreen> {
  // Available color filters matching the design
  final List<String> _availableColors = const [
    'Amber',
    'Brown',
    'Beige',
    'Crimson',
    'Gold',
    'Green',
  ];

  // Currently selected colors (defaults to Brown, allows up to 2 simultaneously)
  final Set<String> _selectedColors = {'Brown'};

  void _toggleColor(String color) {
    setState(() {
      if (_selectedColors.contains(color)) {
        // Only allow deselect if more than one is selected, or allow empty to show all
        _selectedColors.remove(color);
      } else {
        // Max 2 colors at a time
        if (_selectedColors.length >= 2) {
          // Remove the first color and add the new one
          final first = _selectedColors.first;
          _selectedColors.remove(first);
        }
        _selectedColors.add(color);
      }
    });
  }

  List<NailService> _getFilteredServices() {
    if (_selectedColors.isEmpty) {
      return NailService.allNailServices;
    }
    return NailService.allNailServices.where((service) {
      return service.colors.any((c) => _selectedColors.contains(c));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredServices();
    final trending = filtered.where((s) => s.section == 'TRENDING').toList();
    final topRated = filtered.where((s) => s.section == 'TOP RATED').toList();
    final explore =
        filtered.where((s) => s.section == 'EXPLORE THE COLLECTION').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Top Bar with Back Button and "Nails Services" Title
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
                      'Nails Services',
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

              const SizedBox(height: 20),

              // Header: CURATED BEAUTY MENU & Select a service
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
              const SizedBox(height: 4),
              Text(
                'Select a service',
                style: AppTextStyles.editorialTitle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 16),

              // Subheader: FILTER BY COLOUR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FILTER BY COLOUR',
                    style: AppTextStyles.uppercaseSubtitle(
                      fontSize: 11,
                      letterSpacing: 2.0,
                    ),
                  ),
                  if (_selectedColors.isNotEmpty)
                    Text(
                      '(${_selectedColors.length}/2 selected)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Horizontal Color Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: _availableColors.map((color) {
                    final isSelected = _selectedColors.contains(color);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _toggleColor(color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8.5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            color,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Empty State (if no services match)
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.filter_alt_off_outlined,
                        size: 40,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No nail services matching "${_selectedColors.join(', ')}"',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              // 1. TRENDING SECTION
              if (trending.isNotEmpty) ...[
                Text(
                  'TRENDING',
                  style: AppTextStyles.uppercaseSubtitle(
                    fontSize: 11,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                _buildServiceGrid(trending),
                const SizedBox(height: 24),
              ],

              // 2. TOP RATED SECTION
              if (topRated.isNotEmpty) ...[
                Text(
                  'TOP RATED',
                  style: AppTextStyles.uppercaseSubtitle(
                    fontSize: 11,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                _buildServiceGrid(topRated),
                const SizedBox(height: 24),
              ],

              // 3. EXPLORE THE COLLECTION SECTION
              if (explore.isNotEmpty) ...[
                Text(
                  'EXPLORE THE COLLECTION',
                  style: AppTextStyles.uppercaseSubtitle(
                    fontSize: 11,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                _buildServiceGrid(explore),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceGrid(List<NailService> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        return _NailServiceCard(service: services[index]);
      },
    );
  }
}

class _NailServiceCard extends StatelessWidget {
  final NailService service;

  const _NailServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const NailDetailScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
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
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nail Design Cover Image
          Expanded(
            flex: 54,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                service.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primaryLight,
                  child: const Icon(
                    Icons.brush_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

          // Details
          Expanded(
            flex: 46,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Service By',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${service.stylist} • ${service.stylistRole}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Rating Row
                  Row(
                    children: [
                      const Icon(
                        Icons.star_outline_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        service.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '•',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.reviewsCount} Reviews',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Price and Duration Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        service.price,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            service.duration,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

