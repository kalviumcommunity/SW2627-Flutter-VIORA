import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/inspiration_model.dart';
import '../services/inspiration_service.dart';
import 'inspiration_detail_screen.dart';
import 'inspiration_request_screen.dart';
import 'inspiration_responses_screen.dart';

class InspirationGalleryScreen extends StatefulWidget {
  const InspirationGalleryScreen({super.key});

  @override
  State<InspirationGalleryScreen> createState() => _InspirationGalleryScreenState();
}

class _InspirationGalleryScreenState extends State<InspirationGalleryScreen> {
  final InspirationService _inspirationService = InspirationService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  List<InspirationLook> _looks = [];
  bool _isLoading = true;

  final List<String> _categories = ['All', 'Hair', 'Skin', 'Nails', 'Brows & Lashes'];

  @override
  void initState() {
    super.initState();
    _loadLooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLooks() async {
    setState(() => _isLoading = true);
    final results = await _inspirationService.getDiscoveryFeed(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
    );
    if (mounted) {
      setState(() {
        _looks = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'INSPIRATION ATELIER',
          style: AppTextStyles.uppercaseSubtitle(fontSize: 13, letterSpacing: 2.2).copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'My Requests & Proposals',
            icon: const Icon(Icons.mark_chat_unread_outlined, color: AppColors.primary, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InspirationResponsesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.0),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _loadLooks(),
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search styles, balayage, velvet nails...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16, color: AppColors.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                _loadLooks();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter Pills
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 1.0,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                            _loadLooks();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Gallery Grid View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _looks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadLooks,
                        color: AppColors.primary,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _looks.length,
                          itemBuilder: (context, index) {
                            final look = _looks[index];
                            return _buildLookCard(look);
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.9)),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text(
              'REQUEST BESPOKE LOOK CONSULTATION',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const InspirationRequestScreen()),
              );
              if (created == true) {
                _loadLooks();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLookCard(InspirationLook look) {
    final isSaved = _inspirationService.isBookmarked(look.id);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => InspirationDetailScreen(look: look)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Bookmark & Tag
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    look.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 36),
                    ),
                  ),
                  // Gradient vignette
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Category tag
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        look.category.toUpperCase(),
                        style: const TextStyle(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                      ),
                    ),
                  ),
                  // Bookmark button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? AppColors.primary : Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _inspirationService.toggleBookmark(look.id);
                        });
                      },
                    ),
                  ),
                  // Rating banner
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFB300), size: 13),
                        const SizedBox(width: 3),
                        Text(
                          look.rating.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Metadata
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    look.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (look.stylistName != null)
                    Text(
                      'By ${look.stylistName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(
              'No Inspiration Looks Found',
              style: AppTextStyles.editorialTitle(fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try selecting another category or clear your search to explore all curated styles.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

