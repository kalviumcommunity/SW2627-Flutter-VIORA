import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/nail_customization.dart';
import '../models/stylist.dart';
import 'branches_list_screen.dart';
import 'stylist_selection_screen.dart';

class NailDetailScreen extends StatefulWidget {
  const NailDetailScreen({super.key});

  @override
  State<NailDetailScreen> createState() => _NailDetailScreenState();
}

class _NailDetailScreenState extends State<NailDetailScreen> {
  bool _isFavorite = false;

  // Single choice selections with defaults matching mockup
  String _selectedTopCoat = 'Glossy';
  String _selectedPigment = 'Velvet';
  String _selectedOpacity = 'Jelly';
  String _selectedExtension = 'Extensions';
  String _selectedLength = 'Medium';
  String _selectedShape = 'Almond';

  // Multi-choice selections for DESIGNS (strictly max 2 options)
  final Set<String> _selectedDesigns = {'Inverted Ombre'};
  String? _openCategory = 'Ombre & Gradients';

  void _toggleDesignOption(String option) {
    setState(() {
      if (_selectedDesigns.contains(option)) {
        _selectedDesigns.remove(option);
      } else {
        if (_selectedDesigns.length >= 2) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.textPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: const Text(
                'Max 2 options can be selected in Design Section',
                style: TextStyle(fontSize: 12.5, color: Colors.white),
              ),
              duration: const Duration(milliseconds: 1800),
            ),
          );
          return;
        }
        _selectedDesigns.add(option);
      }
    });
  }

  final List<String> _topCoatOptions = const ['Glossy', 'Satin', 'Matte'];
  final List<String> _pigmentOptions = const [
    'Velvet',
    'Chrome',
    'Holographic',
    'Pearlescent',
    'Iridescent',
    'Glitter',
    'None',
  ];
  final List<String> _opacityOptions = const ['Jelly', 'Milky', 'Cream'];
  final List<String> _extensionOptions = const ['Extensions', 'None'];
  final List<String> _lengthOptions = const ['Medium', 'Long', 'Short'];
  final List<String> _shapeOptions = const [
    'Almond',
    'Oval',
    'Square',
    'Squoval',
    'Coffin',
    'Stiletto',
  ];


  int get totalPrice {
    int price = 1800; // Base look price

    // 1. Top Coat (Affects price)
    if (_selectedTopCoat == 'Satin') price += 100;
    if (_selectedTopCoat == 'Matte') price += 150;

    // 2. Pigment (Affects price)
    if (_selectedPigment == 'Chrome') price += 200;
    else if (_selectedPigment == 'Holographic') price += 300;
    else if (_selectedPigment == 'Pearlescent') price += 150;
    else if (_selectedPigment == 'Iridescent') price += 200;
    else if (_selectedPigment == 'Glitter') price += 100;
    else if (_selectedPigment == 'None') price -= 100;

    // 3. Opacity (Affects price)
    if (_selectedOpacity == 'Milky') price += 100;
    else if (_selectedOpacity == 'Cream') price += 150;

    // 4. Extensions (Affects price)
    if (_selectedExtension == 'None') price -= 300;

    // 5. Nail Length: Does NOT matter (₹0 change), as instructed!

    // 6. Nail Shape (Affects price)
    if (_selectedShape == 'Oval' || _selectedShape == 'Square') price += 50;
    else if (_selectedShape == 'Squoval') price += 100;
    else if (_selectedShape == 'Coffin') price += 150;
    else if (_selectedShape == 'Stiletto') price += 200;

    // 7. Designs (Affects price)
    if (_selectedDesigns.isEmpty) {
      price -= 200;
    } else if (_selectedDesigns.length == 1 && _selectedDesigns.contains('Inverted Ombre')) {
      // base design - no change
    } else if (_selectedDesigns.length == 1) {
      price += 50;
    } else if (_selectedDesigns.length == 2) {
      price += 250;
    }

    return price;
  }

  void _onBookLook() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BranchesListScreen(
          isBookingFlow: true,
          bookingServiceTitle: 'Brown Ombre Cat Eye Nails',
          bookingCategory: 'Nails',
          bookingPrice: totalPrice,
          bookingDurationMinutes: 70,
          bookingStylist: Stylist.sampleStylists[0],
          bookingCustomizations: {
            'topCoat': _selectedTopCoat,
            'pigment': _selectedPigment,
            'opacity': _selectedOpacity,
            'extensions': _selectedExtension,
            'length': _selectedLength,
            'shape': _selectedShape,
            'designs': _selectedDesigns.toList(),
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
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
                      'Brown Ombre Cat Eye',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.editorialTitle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.textPrimary,
                          content: Text('Share link copied to clipboard!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
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
                        Icons.share_outlined,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/nail_hero_large.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/nail_brown_cat_eye.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Service Title & Wishlist
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Brown Ombre Cat Eye',
                            style: AppTextStyles.editorialTitle(
                              fontSize: 26,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                          },
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite
                                ? Colors.redAccent
                                : AppColors.textSecondary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Rating
                    Row(
                      children: const [
                        Icon(
                          Icons.star_outline_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '4.0',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '(888 Reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Description
                    const Text(
                      'A rich brown inverted ombré with a soft velvet finish, creating a luminous shimmer that catches the light from every angle.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Duration and Price Badges
                    Row(
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.access_time_rounded,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Approx. 60-80 min',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Row(
                          children: [
                            const Icon(
                              Icons.confirmation_num_outlined,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'From ₹$totalPrice',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Section Heading: REFINE YOUR LOOK
                    Text(
                      'REFINE YOUR LOOK',
                      style: AppTextStyles.uppercaseSubtitle(
                        fontSize: 11,
                        letterSpacing: 2.0,
                      ).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 1. TOP COAT
                    _buildSectionTitle('TOP COAT'),
                    _buildPillRow(
                      options: _topCoatOptions,
                      selected: _selectedTopCoat,
                      onSelect: (v) => setState(() => _selectedTopCoat = v),
                    ),

                    const SizedBox(height: 18),

                    // 2. PIGMENT
                    _buildSectionTitle('PIGMENT'),
                    _buildScrollablePillRow(
                      options: _pigmentOptions,
                      selected: _selectedPigment,
                      onSelect: (v) => setState(() => _selectedPigment = v),
                    ),

                    const SizedBox(height: 18),

                    // 3. OPACITY
                    _buildSectionTitle('OPACITY'),
                    _buildPillRow(
                      options: _opacityOptions,
                      selected: _selectedOpacity,
                      onSelect: (v) => setState(() => _selectedOpacity = v),
                    ),

                    const SizedBox(height: 18),

                    // 4. EXTENSIONS
                    _buildSectionTitle('EXTENSIONS'),
                    _buildPillRow(
                      options: _extensionOptions,
                      selected: _selectedExtension,
                      onSelect: (v) => setState(() => _selectedExtension = v),
                    ),

                    const SizedBox(height: 18),

                    // 5. NAIL LENGTH (Does not affect price)
                    _buildSectionTitle('NAIL LENGTH'),
                    _buildPillRow(
                      options: _lengthOptions,
                      selected: _selectedLength,
                      onSelect: (v) => setState(() => _selectedLength = v),
                    ),

                    const SizedBox(height: 18),

                    // 6. NAIL SHAPE
                    _buildSectionTitle('NAIL SHAPE'),
                    _buildScrollablePillRow(
                      options: _shapeOptions,
                      selected: _selectedShape,
                      onSelect: (v) => setState(() => _selectedShape = v),
                    ),

                    const SizedBox(height: 18),

                    // 7. DESIGNS (Max 2 Options Allowed)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _buildSectionTitle('DESIGNS'),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Max 2 options can be selected in Design Section',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Scrollable Dropdown Columns matching Figma Image 1 & 2
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...DesignCategory.allCategories.map((cat) {
                            final isOpen = _openCategory == cat.name;
                            final hasSelection = cat.options
                                .any((opt) => _selectedDesigns.contains(opt));
                            final isActive = isOpen || hasSelection;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Category Trigger Chip
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_openCategory == cat.name) {
                                          _openCategory = null;
                                        } else {
                                          _openCategory = cat.name;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.primary
                                            : AppColors.surface,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isActive
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 1.2,
                                        ),
                                        boxShadow: isActive
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withOpacity(0.25),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            cat.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isActive
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: isActive
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            isOpen
                                                ? Icons.keyboard_arrow_up_rounded
                                                : Icons.keyboard_arrow_down_rounded,
                                            size: 16,
                                            color: isActive
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Attached Dropdown Card matching Figma Image 1 specifically
                                  if (isOpen) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      width: 185,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFEDE8E1),
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: cat.options.map((option) {
                                          final isSelected =
                                              _selectedDesigns.contains(option);
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 2.5,
                                            ),
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _toggleDesignOption(option),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 150,
                                                ),
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8.5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : const Color(0xFFF0EAE1),
                                                    width: 1.1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    option,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 11.5,
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
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),

                          // "None" option chip to clear designs
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDesigns.clear();
                                  _openCategory = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8.5,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedDesigns.isEmpty &&
                                          _openCategory == null
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _selectedDesigns.isEmpty &&
                                            _openCategory == null
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  'None',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _selectedDesigns.isEmpty &&
                                            _openCategory == null
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _selectedDesigns.isEmpty &&
                                            _openCategory == null
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // BOOK THIS LOOK CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _onBookLook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'BOOK THIS LOOK • ₹$totalPrice',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: Color(0xFF6E6A66),
        ),
      ),
    );
  }

  Widget _buildPillRow({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Row(
      children: options.map((opt) {
        final isSelected = opt == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(opt),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8.5,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1.2,
                ),
              ),
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScrollablePillRow({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8.5,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
