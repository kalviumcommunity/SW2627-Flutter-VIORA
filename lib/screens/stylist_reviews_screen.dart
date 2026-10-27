import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import 'submit_review_screen.dart';

class StylistReviewsScreen extends StatefulWidget {
  final String stylistId;
  final String stylistName;

  const StylistReviewsScreen({
    super.key,
    this.stylistId = 's1',
    this.stylistName = 'Julian Vance',
  });

  @override
  State<StylistReviewsScreen> createState() => _StylistReviewsScreenState();
}

class _StylistReviewsScreenState extends State<StylistReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  List<ReviewItem> _reviews = [];
  StylistReviewStats _stats = const StylistReviewStats();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    final data = await _reviewService.getStylistReviewsWithStats(widget.stylistId);
    if (mounted) {
      setState(() {
        _reviews = data['reviews'] as List<ReviewItem>;
        _stats = data['stats'] as StylistReviewStats;
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
          'CLIENT REVIEWS & RATINGS',
          style: AppTextStyles.uppercaseSubtitle(fontSize: 13, letterSpacing: 2.2).copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review_outlined, color: AppColors.primary, size: 20),
            onPressed: () async {
              final submitted = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => SubmitReviewScreen(
                    stylistId: widget.stylistId,
                    stylistName: widget.stylistName,
                  ),
                ),
              );
              if (submitted == true) {
                _loadReviews();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              slivers: [
                // Summary Scorecard
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.stylistName,
                          style: AppTextStyles.editorialTitle(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Verified Atelier Performance Metrics',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildScoreMetric('OVERALL RATING', _stats.averageRating.toStringAsFixed(2)),
                            _buildScoreMetric('LOOK EXECUTION', _stats.averageLookRating.toStringAsFixed(2)),
                            _buildScoreMetric('TOTAL REVIEWS', '${_stats.totalReviews}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Reviews List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final r = _reviews[index];
                        return _buildReviewTile(r);
                      },
                      childCount: _reviews.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
    );
  }

  Widget _buildScoreMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewTile(ReviewItem r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r.customerName,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFB300), size: 14),
                  const SizedBox(width: 3),
                  Text(
                    r.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          if (r.serviceName.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              r.serviceName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            r.comments,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            '${r.createdAt.day} ${_monthName(r.createdAt.month)} ${r.createdAt.year}',
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }
}




