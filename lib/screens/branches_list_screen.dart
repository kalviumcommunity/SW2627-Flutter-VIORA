import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/salon_branch.dart';
import '../models/stylist.dart';
import '../services/branch_service.dart';
import 'date_time_selection_screen.dart';
import 'customer_main_scaffold.dart';

class BranchesListScreen extends StatefulWidget {
  final String? selectedServiceTitle;
  final int? selectedPrice;
  final String? selectedCategory;
  final String? preselectedBranchName;
  final String? preselectedBranchId;
  final String? preferredStylistName;
  final bool isTab;

  const BranchesListScreen({
    super.key,
    this.selectedServiceTitle,
    this.selectedPrice,
    this.selectedCategory,
    this.preselectedBranchName,
    this.preselectedBranchId,
    this.preferredStylistName,
    this.isTab = false,
  });

  @override
  State<BranchesListScreen> createState() => _BranchesListScreenState();
}

class _BranchesListScreenState extends State<BranchesListScreen> {
  int _selectedTabIndex = 0; // 0: ALL SALONS, 1: POPULAR, 2: NEAREST
  final TextEditingController _searchController = TextEditingController();
  List<SalonBranch> _branches = SalonBranch.sampleBranches;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoading = true);
    final list = await BranchService().getBranches();
    if (mounted && list.isNotEmpty) {
      setState(() {
        _branches = list;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Normalize branch names for comparison (remove bullets, dashes, extra spaces)
  bool _matchesBranchName(String a, String b) {
    String clean(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final cleanA = clean(a);
    final cleanB = clean(b);
    return cleanA.contains(cleanB) || cleanB.contains(cleanA);
  }

  SalonBranch? get _matchingPreselectedBranch {
    if (widget.preselectedBranchName == null && widget.preselectedBranchId == null) {
      return null;
    }
    for (final branch in _branches) {
      if (widget.preselectedBranchId != null && branch.id == widget.preselectedBranchId) {
        return branch;
      }
      if (widget.preselectedBranchName != null &&
          _matchesBranchName(branch.name, widget.preselectedBranchName!)) {
        return branch;
      }
    }
    return null;
  }

  List<SalonBranch> get _filteredBranches {
    final query = _searchController.text.trim().toLowerCase();

    // 1. Text Search Filtering
    List<SalonBranch> list = _branches.where((branch) {
      if (query.isEmpty) return true;
      return branch.name.toLowerCase().contains(query) ||
          branch.address.toLowerCase().contains(query) ||
          branch.openingHours.toLowerCase().contains(query);
    }).toList();

    // 2. Tab Filter / Sort
    if (_selectedTabIndex == 1) {
      // POPULAR: Rank by rating descending, then serviceCount descending
      list.sort((a, b) {
        final cmp = b.rating.compareTo(a.rating);
        if (cmp != 0) return cmp;
        return b.serviceCount.compareTo(a.serviceCount);
      });
    } else if (_selectedTabIndex == 2) {
      // NEAREST: Sort ascending by distance (parsing distance value safely)
      double parseDist(String d) {
        final numStr = d.replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(numStr) ?? 999.0;
      }

      list.sort((a, b) => parseDist(a.distance).compareTo(parseDist(b.distance)));
    }

    // 3. Preselected Branch Prioritization
    final preselected = _matchingPreselectedBranch;
    if (preselected != null && list.any((b) => b.id == preselected.id)) {
      // Pin preselected branch at the top of the list
      list.removeWhere((b) => b.id == preselected.id);
      list.insert(0, preselected);
    }

    return list;
  }

  void _onSelectBranch(SalonBranch branch) {
    // Resolve preferred stylist if provided from rebooking
    Stylist selectedStylist = Stylist.sampleStylists[1]; // default senior stylist
    if (widget.preferredStylistName != null) {
      final pref = widget.preferredStylistName!.toLowerCase();
      final match = Stylist.sampleStylists.firstWhere(
        (s) => !s.isAnyAvailable &&
            (s.name.toLowerCase().contains(pref) || pref.contains(s.name.toLowerCase())),
        orElse: () => Stylist.sampleStylists[1],
      );
      selectedStylist = match;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DateTimeSelectionScreen(
          stylist: selectedStylist,
          lookName: widget.selectedServiceTitle ?? 'Brown Ombre Cat Eye Nails',
          finalPrice: widget.selectedPrice ?? 2600,
          selectedBranchName: branch.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preselected = _matchingPreselectedBranch;
    final isOriginalBranchMissing = widget.preselectedBranchName != null && preselected == null;
    final displayedBranches = _filteredBranches;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    key: const Key('branches_back_button'),
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else if (widget.isTab) {
                        CustomerMainScaffold.switchTab(context, 0);
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
                      'Salons',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.editorialTitle(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Container(
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
                      Icons.map_outlined,
                      size: 19,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Selected Service Context Pill
            if (widget.selectedServiceTitle != null) ...[
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Service: ${widget.selectedServiceTitle}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Rebooking Preselected Salon Banner
            if (preselected != null) ...[
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF6F0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark_added, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ORIGINAL SALON PRESELECTED',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            preselected.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      key: const Key('continue_rebook_preselected_button'),
                      onPressed: () => _onSelectBranch(preselected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Missing / Unavailable Original Salon Alert
            if (isOriginalBranchMissing) ...[
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFF9800), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'The original salon "${widget.preselectedBranchName}" is currently unavailable. Please select an alternative salon below.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Search Bar with Active Filter & Clear Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        key: const Key('salon_search_input'),
                        controller: _searchController,
                        onChanged: (val) => setState(() {}),
                        style: AppTextStyles.inputText.copyWith(fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: 'Search salon or location',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        key: const Key('salon_search_clear_button'),
                        onTap: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.cancel,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Tab Navigation (ALL SALONS, POPULAR, NEAREST)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabItem(
                      label: 'ALL SALONS',
                      index: 0,
                      keyName: 'tab_all_salons',
                    ),
                  ),
                  Expanded(
                    child: _buildTabItem(
                      label: 'POPULAR',
                      index: 1,
                      keyName: 'tab_popular',
                    ),
                  ),
                  Expanded(
                    child: _buildTabItem(
                      label: 'NEAREST',
                      index: 2,
                      keyName: 'tab_nearest',
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border,
            ),

            const SizedBox(height: 14),

            // Branches List or Empty State
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : displayedBranches.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          key: const Key('branches_list_view'),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: displayedBranches.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            final branch = displayedBranches[index];
                            final isPreselected = preselected != null && branch.id == preselected.id;
                            return _SalonBranchCard(
                              branch: branch,
                              isPreselected: isPreselected,
                              onTap: () => _onSelectBranch(branch),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Salons Found',
              style: AppTextStyles.editorialTitle(fontSize: 20),
            ),
            const SizedBox(height: 6),
            const Text(
              'No salons match your search criteria. Try a different query or switch filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _selectedTabIndex = 0);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('RESET FILTERS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({required String label, required int index, required String keyName}) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      key: Key(keyName),
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            letterSpacing: 0.8,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SalonBranchCard extends StatelessWidget {
  final SalonBranch branch;
  final bool isPreselected;
  final VoidCallback onTap;

  const _SalonBranchCard({
    required this.branch,
    this.isPreselected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPreselected ? AppColors.primary : AppColors.border,
            width: isPreselected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isPreselected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isPreselected ? 12 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preselected Header Tag
            if (isPreselected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                color: AppColors.primary,
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'PREVIOUS APPOINTMENT SALON',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

            // Image Header
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Image.asset(
                    branch.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(Icons.storefront, size: 40, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 13, color: AppColors.bronze),
                        const SizedBox(width: 4),
                        Text(
                          '${branch.rating}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      branch.distance,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          branch.name,
                          style: AppTextStyles.editorialTitle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${branch.serviceCount} Services',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    branch.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          branch.openingHours,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPreselected ? 'REBOOK HERE →' : 'SELECT SALON →',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
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
