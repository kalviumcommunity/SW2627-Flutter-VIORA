import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/salon_branch.dart';
import '../models/hair_service.dart';
import '../models/nail_service.dart';
import '../models/stylist.dart';
import '../services/branch_service.dart';
import 'service_details_screen.dart';
import 'branches_list_screen.dart';
import 'stylist_portfolio_screen.dart';

class VioraSearchScreen extends StatefulWidget {
  const VioraSearchScreen({super.key});

  @override
  State<VioraSearchScreen> createState() => _VioraSearchScreenState();
}

class _VioraSearchScreenState extends State<VioraSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0; // 0: ALL, 1: SALONS, 2: SERVICES, 3: STYLISTS
  List<SalonBranch> _branches = SalonBranch.sampleBranches;
  bool _isLoadingBranches = false;

  final List<String> _categories = const ['ALL', 'SALONS', 'SERVICES', 'STYLISTS'];

  final List<String> _trendingSearches = const [
    'Bandra Heritage',
    'Khar West',
    'Layer Cut',
    'Brown Ombre Cat Eye',
    'Christian Dior',
    'Jessica Alba',
    'Colaba',
  ];

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoadingBranches = true);
    final branches = await BranchService().getBranches();
    if (mounted) {
      setState(() {
        if (branches.isNotEmpty) _branches = branches;
        _isLoadingBranches = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SalonBranch> get _filteredBranches {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _branches;
    return _branches.where((b) {
      return b.name.toLowerCase().contains(q) ||
          b.address.toLowerCase().contains(q) ||
          b.openingHours.toLowerCase().contains(q);
    }).toList();
  }

  List<dynamic> get _filteredServices {
    final q = _searchController.text.trim().toLowerCase();
    final List<dynamic> all = [
      ...HairService.allHairCuts,
      ...NailService.allNailServices,
    ];
    if (q.isEmpty) return all;
    return all.where((item) {
      if (item is HairService) {
        return item.title.toLowerCase().contains(q) ||
            item.gender.toLowerCase().contains(q) ||
            item.stylist.toLowerCase().contains(q) ||
            item.cutTypes.any((c) => c.toLowerCase().contains(q));
      } else if (item is NailService) {
        return item.title.toLowerCase().contains(q) ||
            item.stylist.toLowerCase().contains(q) ||
            item.section.toLowerCase().contains(q);
      }
      return false;
    }).toList();
  }

  List<Stylist> get _filteredStylists {
    final q = _searchController.text.trim().toLowerCase();
    final valid = Stylist.sampleStylists.where((s) => !s.isAnyAvailable).toList();
    if (q.isEmpty) return valid;
    return valid.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.role.toLowerCase().contains(q) ||
          s.location.toLowerCase().contains(q);
    }).toList();
  }

  int get _totalResultsCount {
    if (_selectedCategoryIndex == 1) return _filteredBranches.length;
    if (_selectedCategoryIndex == 2) return _filteredServices.length;
    if (_selectedCategoryIndex == 3) return _filteredStylists.length;
    return _filteredBranches.length + _filteredServices.length + _filteredStylists.length;
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final isQueryEmpty = query.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    key: const Key('search_back_button'),
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
                      'Search Atelier',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.editorialTitle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 22,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        key: const Key('home_search_input_field'),
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (val) => setState(() {}),
                        style: AppTextStyles.inputText.copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search salons, services, or stylists...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (query.isNotEmpty)
                      GestureDetector(
                        key: const Key('search_clear_button'),
                        onTap: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.cancel,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Category Filter Pills
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    key: Key('search_tab_${_categories[index].toLowerCase()}'),
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: AppColors.border),

            // Content: Empty State, Trending Quick Picks, or Filtered Results
            Expanded(
              child: _isLoadingBranches
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : isQueryEmpty
                      ? _buildTrendingSection()
                      : _totalResultsCount == 0
                          ? _buildNoResultsState(query)
                          : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'CURATED ATELIER SEARCHES',
              style: AppTextStyles.labelStyle.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _trendingSearches.map((term) {
            return GestureDetector(
              onTap: () {
                _searchController.text = term;
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: term.length),
                );
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      term,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        Text(
          'FEATURED ATELIERS',
          style: AppTextStyles.labelStyle.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ..._branches.take(2).map((b) => _buildSalonCard(b)),
      ],
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_outlined,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Bespoke Results',
              style: AppTextStyles.editorialTitle(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'We could not find any salon, service, or stylist matching "$query".',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'CLEAR SEARCH',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    final showSalons = _selectedCategoryIndex == 0 || _selectedCategoryIndex == 1;
    final showServices = _selectedCategoryIndex == 0 || _selectedCategoryIndex == 2;
    final showStylists = _selectedCategoryIndex == 0 || _selectedCategoryIndex == 3;

    final branches = _filteredBranches;
    final services = _filteredServices;
    final stylists = _filteredStylists;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      children: [
        if (showSalons && branches.isNotEmpty) ...[
          _buildSectionHeader('SALONS & ATELIERS (${branches.length})'),
          const SizedBox(height: 10),
          ...branches.map((b) => _buildSalonCard(b)),
          const SizedBox(height: 18),
        ],

        if (showServices && services.isNotEmpty) ...[
          _buildSectionHeader('SERVICES & TREATMENTS (${services.length})'),
          const SizedBox(height: 10),
          ...services.map((s) => _buildServiceCard(s)),
          const SizedBox(height: 18),
        ],

        if (showStylists && stylists.isNotEmpty) ...[
          _buildSectionHeader('MASTER STYLISTS (${stylists.length})'),
          const SizedBox(height: 10),
          ...stylists.map((st) => _buildStylistCard(st)),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.labelStyle.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSalonCard(SalonBranch branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BranchesListScreen(
                  preselectedBranchName: branch.name,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        branch.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: AppColors.bronze),
                          const SizedBox(width: 3),
                          Text(
                            '${branch.rating}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 2),
                          Text(
                            branch.distance,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(dynamic service) {
    final isHair = service is HairService;
    final title = isHair ? service.title : (service as NailService).title;
    final price = isHair ? service.price : (service as NailService).price;
    final duration = isHair ? service.duration : (service as NailService).duration;
    final stylistName = isHair ? service.stylist : (service as NailService).stylist;
    final rating = isHair ? service.rating : (service as NailService).rating;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ServiceDetailsScreen(
                  serviceName: title,
                  servicePrice: price,
                  serviceDuration: duration,
                  serviceDescription: isHair
                      ? 'Bespoke precision hair artistry and botanical ritual.'
                      : 'Couture nail styling and luxury lacquer craftsmanship.',
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isHair ? Icons.content_cut_outlined : Icons.brush_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'By $stylistName • $duration',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: AppColors.bronze),
                          const SizedBox(width: 3),
                          Text(
                            '$rating',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStylistCard(Stylist stylist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StylistPortfolioScreen(stylistId: stylist.id, stylistName: stylist.name),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                  child: ClipOval(
                    child: stylist.imagePath.isNotEmpty
                        ? Image.asset(
                            stylist.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, color: AppColors.primary),
                          )
                        : const Icon(Icons.person, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stylist.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        stylist.role.isNotEmpty ? stylist.role : 'Senior Artisan',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: AppColors.bronze),
                          const SizedBox(width: 3),
                          Text(
                            '${stylist.overallRating}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${stylist.reviewCount} reviews)',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
