import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/analytics_model.dart';
import '../models/review_model.dart';
import '../services/analytics_service.dart';
import '../services/review_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AnalyticsService _analyticsService = AnalyticsService();
  final ReviewService _reviewService = ReviewService();

  AdminAnalyticsOverview _overview = AdminAnalyticsOverview.sampleOverview;
  List<BranchPerformance> _branches = [];
  List<StylistPerformance> _stylists = [];
  List<PopularService> _popularServices = [];
  List<PopularLook> _popularLooks = [];
  List<ReviewItem> _recentReviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _analyticsService.getOverview(),
      _analyticsService.getBranchPerformance(),
      _analyticsService.getStylistPerformance(),
      _analyticsService.getPopularServices(),
      _analyticsService.getPopularLooks(),
      _reviewService.getStylistReviews('s1'),
    ]);

    if (mounted) {
      setState(() {
        _overview = results[0] as AdminAnalyticsOverview;
        _branches = results[1] as List<BranchPerformance>;
        _stylists = results[2] as List<StylistPerformance>;
        _popularServices = results[3] as List<PopularService>;
        _popularLooks = results[4] as List<PopularLook>;
        _recentReviews = results[5] as List<ReviewItem>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VIORA EXECUTIVE INTELLIGENCE',
              style: AppTextStyles.uppercaseSubtitle(fontSize: 9.5, letterSpacing: 2.0),
            ),
            Text(
              'Admin Analytics Portal',
              style: AppTextStyles.editorialTitle(fontSize: 20),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Branches'),
            Tab(text: 'Stylists'),
            Tab(text: 'Trending'),
            Tab(text: 'Customer Retention'),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadDashboardData,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildBranchesTab(),
                    _buildStylistsTab(),
                    _buildTrendingTab(),
                    _buildCustomerRetentionTab(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Top Revenue Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF24201D), Color(0xFF38322B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL SALON GROSS REVENUE',
                    style: TextStyle(fontSize: 10.5, letterSpacing: 1.8, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '+18.4% vs Last Month',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF81C784)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '₹${_overview.totalRevenue.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Across ${_branches.length} luxury branches in Mumbai',
                style: const TextStyle(fontSize: 12, color: Color(0xFFBBB3A8)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Grid Metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Total Bookings',
                value: '${_overview.totalBookings}',
                subtitle: '${_overview.completedBookings} Completed',
                icon: Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Avg Order Value',
                value: '₹${(_overview.totalRevenue / (_overview.totalBookings > 0 ? _overview.totalBookings : 1)).toStringAsFixed(0)}',
                subtitle: 'Per reservation',
                icon: Icons.currency_rupee,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Atelier Guests',
                value: '${_overview.totalCustomers}',
                subtitle: '${_overview.returningCustomers} Returning Members',
                icon: Icons.people_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Retention Rate',
                value: '${_overview.retentionRate.toStringAsFixed(1)}%',
                subtitle: 'High VIP Loyalty',
                icon: Icons.auto_awesome_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Text(
          'BRANCH LEADERBOARD',
          style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        ..._branches.take(3).map((b) => _buildBranchRow(b)),
      ],
    );
  }

  Widget _buildBranchesTab() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _branches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = _branches[index];
        return _buildBranchRow(b);
      },
    );
  }

  Widget _buildBranchRow(BranchPerformance b) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('${b.city}   ${b.totalBookings} Completed Reservations', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${b.revenue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 2),
              const Text('Revenue', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStylistsTab() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _stylists.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final s = _stylists[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 13, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          '${s.rating.toStringAsFixed(2)}   ${s.totalBookings} Bookings',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${s.revenue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  const Text('Revenue', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendingTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Text(
          'POPULAR SALON SERVICES',
          style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 10),
        ..._popularServices.map((srv) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(srv.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('${srv.category}   ${srv.bookingsCount} reservations', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
                Text('₹${srv.revenue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),

        Text(
          'TRENDING INSPIRATION LOOKS',
          style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 10),
        ..._popularLooks.map((look) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(look.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('${look.category}   ${look.requestsCount} requests', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Text('${look.rating.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCustomerRetentionTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CUSTOMER INTELLIGENCE & RETENTION',
                style: AppTextStyles.uppercaseSubtitle(fontSize: 10, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Member Retention: ${_overview.retentionRate.toStringAsFixed(1)}%',
                style: AppTextStyles.editorialTitle(fontSize: 22),
              ),
              const SizedBox(height: 6),
              const Text(
                'Active retention tracking across customized treatments, beauty consultation quiz results, and personalized style profiles.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _overview.retentionRate / 100.0,
                backgroundColor: AppColors.primaryLight,
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Total Client Profiles',
                value: '${_overview.totalCustomers}',
                subtitle: 'Registered guests',
                icon: Icons.person_search_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'VIP Returning Rate',
                value: '${((_overview.returningCustomers / (_overview.totalCustomers > 0 ? _overview.totalCustomers : 1)) * 100).toStringAsFixed(1)}%',
                subtitle: '${_overview.returningCustomers} loyal clients',
                icon: Icons.repeat,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Text(
          'RECENT CLIENT FEEDBACK & TESTIMONIALS',
          style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 10),
        ..._recentReviews.take(3).map((r) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 13, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text('${r.overallRating} ★', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(r.comments, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
