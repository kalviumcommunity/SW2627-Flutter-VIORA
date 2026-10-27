import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/inspiration_model.dart';
import '../services/inspiration_service.dart';
import 'stylist_portfolio_screen.dart';
import 'stylist_reviews_screen.dart';
import 'stylist_inspiration_respond_screen.dart';

class StylistHomeScreen extends StatefulWidget {
  const StylistHomeScreen({super.key});

  @override
  State<StylistHomeScreen> createState() => _StylistHomeScreenState();
}

class _StylistHomeScreenState extends State<StylistHomeScreen> {
  final InspirationService _inspirationService = InspirationService();
  List<InspirationRequest> _incomingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final requests = await _inspirationService.getRequests();
    if (mounted) {
      setState(() {
        _incomingRequests = requests;
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VIORA ATELIER',
              style: AppTextStyles.uppercaseSubtitle(fontSize: 10, letterSpacing: 2.0),
            ),
            Text(
              'Stylist Executive Portal',
              style: AppTextStyles.editorialTitle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textPrimary),
            onPressed: () => Navigator.pushNamed(context, '/stylist_profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stylist Profile Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF23201D), Color(0xFF38332D)],
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
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/avatar_christian.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary, size: 30),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Julian Vance',
                              style: TextStyle(
                                fontFamily: 'Cormorant Garamond',
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Art Director & Master Colorist   Khar West',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFFC7BDB1)),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.star, size: 12, color: AppColors.primary),
                                      SizedBox(width: 3),
                                      Text(
                                        '4.95 Rating (84 Reviews)',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ],
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

                const SizedBox(height: 20),

                // Stylist KPI Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: "Today's Schedule",
                        value: '4 Bookings',
                        icon: Icons.calendar_today_outlined,
                        color: AppColors.primary,
                        onTap: () => Navigator.pushNamed(context, '/stylist_schedule'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Look Requests',
                        value: '${_incomingRequests.length} Pending',
                        icon: Icons.auto_awesome_outlined,
                        color: const Color(0xFF8A6D3B),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Portfolio Looks',
                        value: '12 Published',
                        icon: Icons.photo_library_outlined,
                        color: const Color(0xFF5B7065),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StylistPortfolioScreen(
                              stylistId: 's1',
                              stylistName: 'Julian Vance',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Guest Reviews',
                        value: '4.95 ★ (84)',
                        icon: Icons.star_outline_rounded,
                        color: const Color(0xFF9C6A4A),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StylistReviewsScreen(
                              stylistId: 's1',
                              stylistName: 'Julian Vance',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Incoming Look Requests
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'INCOMING INSPIRATION REQUESTS',
                      style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.5),
                    ),
                    Text(
                      '${_incomingRequests.length} Waiting',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.primary)))
                else if (_incomingRequests.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text('No pending consultation requests at this moment.', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ..._incomingRequests.map((req) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                req.customerName ?? 'VIP Client',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  req.category,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            req.description.isNotEmpty ? req.description : (req.notes ?? 'Custom bespoke consultation'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Budget: ${req.budgetRange ?? "Flexible"}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => StylistInspirationRespondScreen(request: req),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadData();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: const Text(
                                  'REVIEW & PROPOSE',
                                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                // Atelier Stylist Management Shortcuts
                Text(
                  'ATELIER APPOINTMENTS & OPERATIONS',
                  style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.event_note_outlined,
                  title: 'Today\'s Appointment Details',
                  subtitle: 'Client consultation notes, selected services & add-ons',
                  onTap: () => Navigator.pushNamed(context, '/stylist_appointment_details'),
                ),
                _buildActionTile(
                  icon: Icons.schedule_outlined,
                  title: 'Working Schedule & Breaks',
                  subtitle: 'Update weekly roster, consultation slots, and availability',
                  onTap: () => Navigator.pushNamed(context, '/stylist_schedule'),
                ),
                _buildActionTile(
                  icon: Icons.spa_outlined,
                  title: 'My Specialties & Services',
                  subtitle: 'Configure assigned salon services and bespoke pricing',
                  onTap: () => Navigator.pushNamed(context, '/stylist_services'),
                ),
                _buildActionTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Manage Visual Portfolio',
                  subtitle: 'Upload creations, balayage formulas, and seasonal transformations',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StylistPortfolioScreen(
                        stylistId: 's1',
                        stylistName: 'Julian Vance',
                      ),
                    ),
                  ),
                ),
                _buildActionTile(
                  icon: Icons.reviews_outlined,
                  title: 'Client Reviews & Ratings',
                  subtitle: 'Examine guest feedback, look ratings, and member testimonials',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StylistReviewsScreen(
                        stylistId: 's1',
                        stylistName: 'Julian Vance',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 20, color: color),
                const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
      ),
    );
  }
}
