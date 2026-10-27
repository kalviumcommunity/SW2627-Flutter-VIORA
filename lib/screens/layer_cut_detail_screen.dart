import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'stylist_selection_screen.dart';

class LayerCutDetailScreen extends StatefulWidget {
  final String initialTexture;
  final String initialLength;

  const LayerCutDetailScreen({
    super.key,
    this.initialTexture = 'Straight',
    this.initialLength = 'Long',
  });

  @override
  State<LayerCutDetailScreen> createState() => _LayerCutDetailScreenState();
}

class _LayerCutDetailScreenState extends State<LayerCutDetailScreen> {
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  // Core selections
  final String _title = 'Layer Cut';
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
  final List<String> _fringeOptions = const ['Curtain Bangs', 'Wispy Fringe', 'Bottleneck', 'No Fringe'];
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

  // The 3 user uploaded photos for Straight & Long hair
  final List<Map<String, String>> _straightLongAngles = const [
    {
      'image': 'assets/images/layer_cut_front.jpg',
      'label': 'Front Angle • Face-Framing Cascading Layers',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_side.jpg',
      'label': 'Side Profile • Flowing Tapered Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_back.jpg',
      'label': 'Back Angle • Tiered V-Shape Cascading Layers',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The 3 user uploaded photos for Straight & Medium hair
  final List<Map<String, String>> _straightMediumAngles = const [
    {
      'image': 'assets/images/layer_cut_med_front.jpg',
      'label': 'Front Angle • Face-Framing Curtain Layers',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_med_side.jpg',
      'label': 'Side Profile • Feathered Mid-Length Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_med_back.jpg',
      'label': 'Back Angle • Soft Cascading Curved Layers',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The 3 user uploaded photos for Straight & Short hair
  final List<Map<String, String>> _straightShortAngles = const [
    {
      'image': 'assets/images/layer_cut_short_front.jpg',
      'label': 'Front Angle • Face-Framing Short Layers',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_short_side.jpg',
      'label': 'Side Profile • Tapered Airy Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_short_back.jpg',
      'label': 'Back Angle • Feathered Texturized Layers',
      'badge': 'Back View (3/3)',
    },
  ];

  // The 3 user uploaded photos for Wavy & Long hair
  final List<Map<String, String>> _wavyLongAngles = const [
    {
      'image': 'assets/images/layer_cut_wavy_long_front.jpg',
      'label': 'Front Angle • Cascading Beach Waves & Bangs',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_wavy_long_side.jpg',
      'label': 'Side Profile • Voluminous S-Wave Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_wavy_long_back.jpg',
      'label': 'Back Angle • Deep Mermaid Waves & Layers',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The 3 user uploaded photos for Wavy & Medium hair
  final List<Map<String, String>> _wavyMediumAngles = const [
    {
      'image': 'assets/images/layer_cut_wavy_med_front.jpg',
      'label': 'Front Angle • Soft Face-Framing Waves & Curtain Fringe',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_wavy_med_side.jpg',
      'label': 'Side Profile • Feathered Mid-Length S-Waves',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_wavy_med_back.jpg',
      'label': 'Back Angle • Cascading Curved Waves & Layers',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The 3 user uploaded photos for Wavy & Short hair
  final List<Map<String, String>> _wavyShortAngles = const [
    {
      'image': 'assets/images/layer_cut_wavy_short_front.jpg',
      'label': 'Front Angle • Textured Beach Waves & Curtain Fringe',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_wavy_short_side.jpg',
      'label': 'Side Profile • Tousled Airy Short Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_wavy_short_back.jpg',
      'label': 'Back Angle • Feathered Curved Waves & Bob Layers',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The 3 user uploaded photos for Curly & Long hair
  final List<Map<String, String>> _curlyLongAngles = const [
    {
      'image': 'assets/images/layer_cut_curly_long_front.jpg',
      'label': 'Front Angle • Voluminous Defined Ringlets & Fringe',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_curly_long_side.jpg',
      'label': 'Side Profile • Sculpted Curly Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_curly_long_back.jpg',
      'label': 'Back Angle • Cascading Spiral Layers & Fullness',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The 3 user uploaded photos for Curly & Medium hair
  final List<Map<String, String>> _curlyMediumAngles = const [
    {
      'image': 'assets/images/layer_cut_curly_med_front.jpg',
      'label': 'Front Angle • Mid-Length Spiral Curls & Framing Fringe',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_curly_med_side.jpg',
      'label': 'Side Profile • Defined Bouncy Ringlet Layers',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_curly_med_back.jpg',
      'label': 'Back Angle • Cascading Curved Curls & Volume',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The 3 user uploaded photos for Curly & Short hair
  final List<Map<String, String>> _curlyShortAngles = const [
    {
      'image': 'assets/images/layer_cut_curly_short_front.jpg',
      'label': 'Front Angle • Bouncy Curly Bob & Curtain Fringe',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_curly_short_side.jpg',
      'label': 'Side Profile • Tousled Voluminous Short Silhouette',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_curly_short_back.jpg',
      'label': 'Back Angle • Feathered Rounded Curls & Layers',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The 3 user uploaded photos for Coily & Long hair
  final List<Map<String, String>> _coilyLongAngles = const [
    {
      'image': 'assets/images/layer_cut_coily_long_front.jpg',
      'label': 'Front Angle • Defined Spiral Cascades & Crown Volume',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_coily_long_side.jpg',
      'label': 'Side Profile • Multi-Tiered Coily Silhouette & Taper',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_coily_long_back.jpg',
      'label': 'Back Angle • Flowing Dimensional Coil Graduation',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The 3 user uploaded photos for Coily & Medium hair
  final List<Map<String, String>> _coilyMediumAngles = const [
    {
      'image': 'assets/images/layer_cut_coily_med_front.jpg',
      'label': 'Front Angle • Defined Ringlets & Collarbone Coils',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_coily_med_side.jpg',
      'label': 'Side Profile • Sculpted Coily Silhouette & Face Layers',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_coily_med_back.jpg',
      'label': 'Back Angle • V-Shaped Dimensional Coily Graduation',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  // The 3 user uploaded photos for Coily & Short hair
  final List<Map<String, String>> _coilyShortAngles = const [
    {
      'image': 'assets/images/layer_cut_coily_short_front.jpg',
      'label': 'Front Angle • Voluminous Coily Bob & Curly Bangs',
      'badge': 'Front View (1/3)',
    },
    {
      'image': 'assets/images/layer_cut_coily_short_side.jpg',
      'label': 'Side Profile • Structured Rounded Coil Graduation',
      'badge': 'Side Profile (2/3)',
    },
    {
      'image': 'assets/images/layer_cut_coily_short_back.jpg',
      'label': 'Back Angle • Feathered Rounded Coily Bob Contour',
      'badge': 'Back Cascading (3/3)',
    },
  ];

  List<Map<String, String>> get _currentHeroImages {
    if (_selectedTexture == 'Straight' && _selectedLength == 'Long') {
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
    if (_selectedTexture == 'Coily') {
      return _coilyMediumAngles;
    }
    if (_selectedTexture == 'Curly') {
      return _curlyMediumAngles;
    }
    if (_selectedTexture == 'Wavy') {
      return _wavyMediumAngles;
    }
    if (_selectedTexture == 'Straight') {
      return _straightShortAngles;
    }
    return [
      {
        'image': 'assets/images/layer_cut_short_front.jpg',
        'label': 'Layer Cut Style Preview',
        'badge': 'Look Preview',
      }
    ];
  }


  int get totalPrice {
    int price = 2400; // Base Layer Cut price

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

    // Add-on Care
    if (_selectedCare == 'K18 Molecular Treatment') price += 650;
    else if (_selectedCare == 'Gloss Tonality Shield') price += 450;
    else if (_selectedCare == 'Scalp Detox Scrub') price += 350;

    return price;
  }

  void _onBookLook() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StylistSelectionScreen(
          lookName: '$_title ($_selectedTexture • $_selectedLength • $_selectedStyling)',
          basePrice: totalPrice,
          customizations: {
            'texture': _selectedTexture,
            'length': _selectedLength,
            'fringe': _selectedFringe,
            'styling': _selectedStyling,
            'care': _selectedCare,
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                      _title,
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
                          content: Text('Look link copied to clipboard!'),
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

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HERO CAROUSEL FOR STRAIGHT & LONG
                    _buildHeroCarousel(),

                    const SizedBox(height: 18),

                    // Title & Wishlist
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
                                style: AppTextStyles.editorialTitle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Service By Christian Dior • Master Stylist',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Icon(
                              _isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _isFavorite
                                  ? Colors.redAccent
                                  : AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Rating & Duration Stats
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '4.9',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '(580 Reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('•', style: TextStyle(color: AppColors.border)),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '60-75 min',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Editorial Description
                    Text(
                      'Featherweight cascading layers tailored precisely to your facial contours and natural texture. Creates fluid movement, lightweight volume, and effortless lived-in texture that grows out seamlessly.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSecondary.withOpacity(0.9),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 18),

                    // Section Heading: REFINE THE LOOK
                    Text(
                      'REFINE THE LOOK',
                      style: AppTextStyles.uppercaseSubtitle(
                        fontSize: 11.5,
                        letterSpacing: 2.0,
                      ).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select texture and length to preview customized angles',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 1. HAIR TEXTURE
                    _buildSectionTitle('HAIR TEXTURE'),
                    _buildPillRow(
                      options: _textureOptions,
                      selected: _selectedTexture,
                      onSelect: (v) {
                        setState(() {
                          _selectedTexture = v;
                          final currentOptions = _stylingOptionsByTexture[v] ?? [];
                          if (!currentOptions.contains(_selectedStyling)) {
                            _selectedStyling = currentOptions.isNotEmpty ? currentOptions.first : 'Signature Blowout';
                          }
                          _currentImageIndex = 0;
                        });
                        if (_pageController.hasClients) {
                          _pageController.jumpToPage(0);
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // 2. HAIR LENGTH
                    _buildSectionTitle('HAIR LENGTH'),
                    _buildPillRow(
                      options: _lengthOptions,
                      selected: _selectedLength,
                      onSelect: (v) {
                        setState(() {
                          _selectedLength = v;
                          _currentImageIndex = 0;
                        });
                        if (_pageController.hasClients) {
                          _pageController.jumpToPage(0);
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // 3. FRINGE & BANGS
                    _buildSectionTitle('FRINGE & BANGS'),
                    _buildScrollablePillRow(
                      options: _fringeOptions,
                      selected: _selectedFringe,
                      onSelect: (v) => setState(() => _selectedFringe = v),
                    ),

                    const SizedBox(height: 20),

                    // 4. STYLING & FINISH
                    _buildSectionTitle('STYLING & FINISH'),
                    _buildScrollablePillRow(
                      options: _currentStylingOptions,
                      selected: _selectedStyling,
                      onSelect: (v) => setState(() => _selectedStyling = v),
                    ),

                    const SizedBox(height: 20),

                    // 5. ADD-ON CARE
                    _buildSectionTitle('ADD-ON CARE'),
                    _buildScrollablePillRow(
                      options: _careOptions,
                      selected: _selectedCare,
                      onSelect: (v) => setState(() => _selectedCare = v),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // BOTTOM BAR WITH DYNAMIC PRICE & BOOK THIS LOOK BUTTON
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.border, width: 1.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onBookLook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(
                      'BOOK THIS LOOK • ₹$totalPrice',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HERO CAROUSEL WIDGET
  Widget _buildHeroCarousel() {
    final images = _currentHeroImages;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: double.infinity,
              height: 420,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = images[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        item['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(
                            Icons.face,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      // Top gradient for badge contrast
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bottom gradient for subtitle
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Angle Badge (top left)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.remove_red_eye_outlined,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                item['badge']!,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Angle description (bottom left)
                      Positioned(
                        bottom: 12,
                        left: 14,
                        right: 80,
                        child: Text(
                          item['label']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // CHEVRONS FOR DESKTOP / EASY TAP
            if (images.length > 1) ...[
              // Left Chevron
              Positioned(
                left: 10,
                top: 190,
                child: GestureDetector(
                  onTap: () {
                    if (_currentImageIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              // Right Chevron
              Positioned(
                right: 10,
                top: 190,
                child: GestureDetector(
                  onTap: () {
                    if (_currentImageIndex < images.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

              // DOTS INDICATOR (Bottom Right)
              Positioned(
                bottom: 12,
                right: 14,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(images.length, (index) {
                    final isActive = index == _currentImageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(left: 4),
                      width: isActive ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // CLEAN PILL ROW (Standard row, evenly spaced)
  Widget _buildPillRow({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Row(
      children: options.map((opt) {
        final isSelected = opt == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.textPrimary : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.textPrimary : AppColors.border,
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  opt,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // CLEAN SCROLLABLE PILL ROW (for 4+ options)
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.textPrimary : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.textPrimary : AppColors.border,
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
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
