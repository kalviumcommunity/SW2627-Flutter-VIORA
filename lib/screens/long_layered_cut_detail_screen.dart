import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'stylist_selection_screen.dart';

class LongLayeredCutDetailScreen extends StatefulWidget {
  final String initialTexture;
  final String initialLength;

  const LongLayeredCutDetailScreen({
    super.key,
    this.initialTexture = 'Straight',
    this.initialLength = 'Long',
  });

  @override
  State<LongLayeredCutDetailScreen> createState() => _LongLayeredCutDetailScreenState();
}

class _LongLayeredCutDetailScreenState extends State<LongLayeredCutDetailScreen> {
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  // Core selections
  final String _title = 'Long Layered Cut';
  late String _selectedTexture;
  late String _selectedLength;
  String _selectedFringe = 'Curtain Bangs';
  late String _selectedStyling;
  String _selectedCare = 'K18 Molecular Treatment';

  @override
  void initState() {
    super.initState();
    _selectedTexture = widget.initialTexture;
    _selectedLength = widget.initialLength;
    final opts = _stylingOptionsByTexture[_selectedTexture] ?? _stylingOptionsByTexture['Straight']!;
    _selectedStyling = opts.first;
  }

  final List<String> _textureOptions = const ['Straight', 'Wavy', 'Curly', 'Coily'];
  final List<String> _lengthOptions = const ['Long', 'Medium', 'Short'];
  final List<String> _fringeOptions = const ['Curtain Bangs', 'Wispy Fringe', 'Bottleneck', 'No Bangs'];
  final Map<String, List<String>> _stylingOptionsByTexture = const {
    'Straight': ['Signature Blowout', 'Sleek Glass Finish', 'Soft Waves', 'Natural Polish'],
    'Wavy': ['Beach Waves', 'Bouncy Blowout', 'Diffused Waves', 'Sleek Smooth Press'],
    'Curly': ['Diffused Curls', 'Voluminous Sculpt', 'Hydration Glaze', 'Thermal Silk Press'],
    'Coily': ['Twist-Out Definition', 'Diffused Coil Set', 'Crown Sculpt', 'Nourishing Silk Press'],
  };

  List<String> get _currentStylingOptions =>
      _stylingOptionsByTexture[_selectedTexture] ?? _stylingOptionsByTexture['Straight']!;

  final List<String> _careOptions = const [
    'K18 Molecular Treatment',
    'Gloss Tonality Shield',
    'Scalp Detox Scrub',
    'None',
  ];

  // Dedicated photoshoot photos for Straight & Long hair (Curtain Bangs) on Long Layered Cut
  final List<Map<String, String>> _straightLongAngles = const [
    {
      'image': 'assets/images/long_layered_cut_front.jpg',
      'label': 'Front Angle • Face-Framing Cascading Layers (Curtain Bangs)',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_side.jpg',
      'label': 'Side Profile • Flowing Tapered Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_back.jpg',
      'label': 'Back Angle • Tiered Cascading Lengths',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // Dedicated photoshoot photos for Straight & Long hair (No Bangs) on Long Layered Cut
  final List<Map<String, String>> _straightLongNoBangsAngles = const [
    {
      'image': 'assets/images/long_layered_cut_straight_long_nobangs_front.jpg',
      'label': 'Front Angle • Clean Face-Framing Flowing Layers (No Bangs)',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_straight_long_nobangs_side.jpg',
      'label': 'Side Profile • Seamless Sleek Tapered Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_straight_long_nobangs_back.jpg',
      'label': 'Back Angle • Deep Cascading V-Cut Layers & Lengths',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The photos for Straight & Medium hair
  final List<Map<String, String>> _straightMediumAngles = const [
    {
      'image': 'assets/images/long_layered_cut_med_front.jpg',
      'label': 'Front Angle • Face-Framing Curtain Layers',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_med_side.jpg',
      'label': 'Side Profile • Feathered Mid-Length Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_med_back.jpg',
      'label': 'Back Angle • Tiered Cascading Mid-Length Layers',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The photos for Straight & Short hair
  final List<Map<String, String>> _straightShortAngles = const [
    {
      'image': 'assets/images/long_layered_cut_short_front.jpg',
      'label': 'Front Angle • Face-Framing Soft Layers',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_short_side.jpg',
      'label': 'Side Profile • Tapered Airy Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_short_back.jpg',
      'label': 'Back Angle • Feathered Texturized Layers',
      'badge': 'Back View (3/3)',
    },
  ];

  // Wavy & Long hair
  final List<Map<String, String>> _wavyLongAngles = const [
    {
      'image': 'assets/images/long_layered_cut_wavy_long_front.jpg',
      'label': 'Front Angle • Cascading Beach Waves & Bangs',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_wavy_long_side.jpg',
      'label': 'Side Profile • Voluminous S-Wave Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_wavy_long_back.jpg',
      'label': 'Back Angle • Deep Mermaid Waves & Layers',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // Wavy & Medium hair
  final List<Map<String, String>> _wavyMediumAngles = const [
    {
      'image': 'assets/images/long_layered_cut_wavy_med_front.jpg',
      'label': 'Front Angle • Soft Face-Framing Waves & Curtain Fringe',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_wavy_med_side.jpg',
      'label': 'Side Profile • Feathered Mid-Length S-Waves',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_wavy_med_back.jpg',
      'label': 'Back Angle • Cascading Curved Waves & Layers',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // Wavy & Short hair
  final List<Map<String, String>> _wavyShortAngles = const [
    {
      'image': 'assets/images/long_layered_cut_wavy_short_front.jpg',
      'label': 'Front Angle • Textured Beach Waves & Curtain Fringe',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_wavy_short_side.jpg',
      'label': 'Side Profile • Tousled Airy Short Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_wavy_short_back.jpg',
      'label': 'Back Angle • Feathered Curved Waves & Bob Layers',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // Curly & Long hair
  final List<Map<String, String>> _curlyLongAngles = const [
    {
      'image': 'assets/images/long_layered_cut_curly_long_front.jpg',
      'label': 'Front Angle • Voluminous Defined Ringlets & Fringe',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_curly_long_side.jpg',
      'label': 'Side Profile • Sculpted Curly Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_curly_long_back.jpg',
      'label': 'Back Angle • Cascading Spiral Layers & Fullness',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // Curly & Medium hair
  final List<Map<String, String>> _curlyMediumAngles = const [
    {
      'image': 'assets/images/long_layered_cut_curly_med_front.jpg',
      'label': 'Front Angle • Mid-Length Spiral Curls & Framing Fringe',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_curly_med_side.jpg',
      'label': 'Side Profile • Defined Bouncy Ringlet Layers',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_curly_med_back.jpg',
      'label': 'Back Angle • Cascading Curved Curls & Volume',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // Curly & Short hair
  final List<Map<String, String>> _curlyShortAngles = const [
    {
      'image': 'assets/images/long_layered_cut_curly_short_front.jpg',
      'label': 'Front Angle • Bouncy Curly Bob & Curtain Fringe',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_curly_short_side.jpg',
      'label': 'Side Profile • Tousled Voluminous Short Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_curly_short_back.jpg',
      'label': 'Back Angle • Feathered Rounded Curls & Layers',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // Coily & Long hair
  final List<Map<String, String>> _coilyLongAngles = const [
    {
      'image': 'assets/images/long_layered_cut_coily_long_front.jpg',
      'label': 'Front Angle • Defined Spiral Cascades & Crown Volume',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_coily_long_side.jpg',
      'label': 'Side Profile • Multi-Tiered Coily Silhouette & Taper',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_coily_long_back.jpg',
      'label': 'Back Angle • Flowing Dimensional Coil Graduation',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // Coily & Medium hair
  final List<Map<String, String>> _coilyMediumAngles = const [
    {
      'image': 'assets/images/long_layered_cut_coily_med_front.jpg',
      'label': 'Front Angle • Defined Ringlets & Collarbone Coils',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_coily_med_side.jpg',
      'label': 'Side Profile • Hydrated Spring-Back Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_coily_med_back.jpg',
      'label': 'Back Angle • Cascading Curved Coils & Fullness',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // Coily & Short hair
  final List<Map<String, String>> _coilyShortAngles = const [
    {
      'image': 'assets/images/long_layered_cut_coily_short_front.jpg',
      'label': 'Front Angle • Sculpted Crown Coils & Framed Fringe',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_coily_short_side.jpg',
      'label': 'Side Profile • Structured Rounded Coil Graduation',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/long_layered_cut_coily_short_back.jpg',
      'label': 'Back Angle • Feathered Rounded Coily Bob Contour',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  List<Map<String, String>> get _currentHeroImages {
    if (_selectedTexture == 'Straight' && _selectedLength == 'Long') {
      if (_selectedFringe == 'No Bangs' || _selectedFringe == 'No Fringe') {
        return _straightLongNoBangsAngles;
      }
      return _straightLongAngles;
    }
    if (_selectedTexture == 'Straight' && _selectedLength == 'Medium') {
      return _straightMediumAngles;
    }
    if (_selectedTexture == 'Straight' && _selectedLength == 'Short') {
      return _straightShortAngles;
    }
    if (_selectedTexture == 'Wavy' && _selectedLength == 'Long') {
      return _wavyLongAngles;
    }
    if (_selectedTexture == 'Wavy' && _selectedLength == 'Medium') {
      return _wavyMediumAngles;
    }
    if (_selectedTexture == 'Wavy' && _selectedLength == 'Short') {
      return _wavyShortAngles;
    }
    if (_selectedTexture == 'Curly' && _selectedLength == 'Long') {
      return _curlyLongAngles;
    }
    if (_selectedTexture == 'Curly' && _selectedLength == 'Medium') {
      return _curlyMediumAngles;
    }
    if (_selectedTexture == 'Curly' && _selectedLength == 'Short') {
      return _curlyShortAngles;
    }
    if (_selectedTexture == 'Coily' && _selectedLength == 'Long') {
      return _coilyLongAngles;
    }
    if (_selectedTexture == 'Coily' && _selectedLength == 'Medium') {
      return _coilyMediumAngles;
    }
    if (_selectedTexture == 'Coily' && _selectedLength == 'Short') {
      return _coilyShortAngles;
    }
    return _straightLongAngles;
  }

  int get totalPrice {
    int price = 2600; // Base Long Layered Cut price

    // Hair Length pricing
    if (_selectedLength == 'Long') price += 200;
    else if (_selectedLength == 'Short') price -= 150;

    // Fringe & Bangs
    if (_selectedFringe == 'Curtain Bangs') price += 150;
    else if (_selectedFringe == 'Wispy Fringe') price += 100;
    else if (_selectedFringe == 'Bottleneck') price += 120;

    // Styling & Finish
    if (_selectedStyling.contains('Silk') || _selectedStyling.contains('Glass') || _selectedStyling.contains('Press')) {
      price += 350;
    } else if (_selectedStyling.contains('Blowout') && _selectedStyling != 'Signature Blowout') {
      price += 250;
    } else if (_selectedStyling == 'Voluminous Sculpt' || _selectedStyling == 'Crown Sculpt') {
      price += 250;
    } else if (_selectedStyling == 'Soft Waves' || _selectedStyling == 'Diffused Waves' || _selectedStyling == 'Diffused Coil Set' || _selectedStyling == 'Hydration Glaze') {
      price += 200;
    }

    // Care Treatment
    if (_selectedCare == 'K18 Molecular Treatment') price += 850;
    else if (_selectedCare == 'Gloss Tonality Shield') price += 600;
    else if (_selectedCare == 'Scalp Detox Scrub') price += 450;

    return price;
  }

  void _onTextureChanged(String texture) {
    setState(() {
      _selectedTexture = texture;
      _currentImageIndex = 0;
      final opts = _stylingOptionsByTexture[texture] ?? _stylingOptionsByTexture['Straight']!;
      if (!opts.contains(_selectedStyling)) {
        _selectedStyling = opts.first;
      }
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _onLengthChanged(String length) {
    setState(() {
      _selectedLength = length;
      _currentImageIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _bookThisLook() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StylistSelectionScreen(
          lookName: '$_title ($_selectedTexture • $_selectedLength • $_selectedStyling)',
          basePrice: totalPrice,
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
    final images = _currentHeroImages;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    _title,
                    style: AppTextStyles.h3.copyWith(
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? AppColors.gold : AppColors.secondaryText,
                    ),
                    onPressed: () => setState(() => _isFavorite = !_isFavorite),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image Carousel Container (Elongated hero)
                    Container(
                      height: 380,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: images.length,
                              onPageChanged: (idx) {
                                setState(() => _currentImageIndex = idx);
                              },
                              itemBuilder: (context, idx) {
                                return Image.asset(
                                  images[idx]['image']!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Angle Badge
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  images[_currentImageIndex]['badge'] ?? 'Preview',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            // 360 Indicator Badge
                            Positioned(
                              top: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.threed_rotation, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      '360° Studio',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Carousel Dots
                            Positioned(
                              bottom: 14,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(images.length, (idx) {
                                  final active = idx == _currentImageIndex;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    width: active ? 18 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: active ? AppColors.gold : Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _title,
                                style: AppTextStyles.h2.copyWith(
                                  fontFamily: 'Playfair Display',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: AppColors.gold, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.9 (620 reviews) • 65-75 min',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Elongated luxury silhouette featuring cascading tiers and framing layers. Creates fluid dimension, lightweight movement, and graceful contours.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Hair Texture Selector
                    Text(
                      'HAIR TEXTURE',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _textureOptions.map((tex) {
                        final isSel = tex == _selectedTexture;
                        return ChoiceChip(
                          label: Text(tex),
                          selected: isSel,
                          onSelected: (_) => _onTextureChanged(tex),
                          selectedColor: AppColors.gold,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.primaryText,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSel ? AppColors.gold : AppColors.cardBorder,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Hair Length Selector
                    Text(
                      'HAIR LENGTH',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _lengthOptions.map((len) {
                        final isSel = len == _selectedLength;
                        return ChoiceChip(
                          label: Text(len),
                          selected: isSel,
                          onSelected: (_) => _onLengthChanged(len),
                          selectedColor: AppColors.gold,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.primaryText,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSel ? AppColors.gold : AppColors.cardBorder,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Fringe & Bangs
                    Text(
                      'FRINGE & FACE-FRAMING',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _fringeOptions.map((fringe) {
                        final isSel = fringe == _selectedFringe;
                        return ChoiceChip(
                          label: Text(fringe),
                          selected: isSel,
                          onSelected: (_) => setState(() {
                            _selectedFringe = fringe;
                            _currentImageIndex = 0;
                          }),
                          selectedColor: AppColors.gold,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.primaryText,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSel ? AppColors.gold : AppColors.cardBorder,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Styling & Finish
                    Text(
                      'STYLING & FINISH',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _currentStylingOptions.map((sty) {
                        final isSel = sty == _selectedStyling;
                        return ChoiceChip(
                          label: Text(sty),
                          selected: isSel,
                          onSelected: (_) => setState(() => _selectedStyling = sty),
                          selectedColor: AppColors.gold,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.primaryText,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSel ? AppColors.gold : AppColors.cardBorder,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Care Treatment Add-on
                    Text(
                      'POST-CUT CARE & TREATMENT',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _careOptions.map((care) {
                        final isSel = care == _selectedCare;
                        return ChoiceChip(
                          label: Text(care),
                          selected: isSel,
                          onSelected: (_) => setState(() => _selectedCare = care),
                          selectedColor: AppColors.gold,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.primaryText,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSel ? AppColors.gold : AppColors.cardBorder,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // Bottom Floating Booking Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Look Price',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(
                        '₹${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _bookThisLook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'BOOK THIS LOOK',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
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
