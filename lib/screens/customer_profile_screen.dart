import 'customer_main_scaffold.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/firebase/firebase_manager.dart';
import '../services/auth_service.dart';
import 'my_appointments_screen.dart';
import 'services_categories_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  final bool isTab;
  const CustomerProfileScreen({super.key, this.isTab = false});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool _smsReminders = true;
  bool _vipInvitations = true;
  bool _styleForecasts = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: FirebaseManager().auth.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseManager().auth.currentUser;
        final isLoggedIn = user != null && !user.isGuest;
        final name = isLoggedIn ? user.name : 'Valued Atelier Guest';
        final email = isLoggedIn ? user.email : 'guest.client@viora-luxury.com';
        final tier = isLoggedIn ? user.tierName : 'Guest Privilege Access';
        final points = isLoggedIn ? user.loyaltyPoints : 500;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
              onPressed: () {
                if (widget.isTab) {
                  CustomerMainScaffold.switchTab(context, 0);
                } else if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  CustomerMainScaffold.switchTab(context, 0);
                }
              },
            ),
            title: Text(
              'My Profile',
              style: AppTextStyles.editorialTitle(
                fontSize: 20,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User identity header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isLoggedIn ? user.userInitials : 'VI',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.editorialTitle(fontSize: 20)),
                              const SizedBox(height: 2),
                              Text(email, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tier,
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Luxury VIP Membership Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF221F1C), Color(0xFF38332D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
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
                              'VIORA ATELIER PASS',
                              style: TextStyle(fontSize: 11, letterSpacing: 2.0, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            Icon(Icons.workspace_premium, color: AppColors.primary, size: 20),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$points PRIVILEGE POINTS',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, letterSpacing: 1.0, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Card Tier: $tier',
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Exclusive Member Privileges', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
                            const Text('REDEEM >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 1: Beauty Journey & Diagnostics
                  Text(
                    'BEAUTY JOURNEY & DIAGNOSTICS',
                    style: AppTextStyles.labelStyle.copyWith(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildPreferenceRow('Hair Texture', 'Fine-to-Medium Wavy'),
                        const Divider(height: 18),
                        _buildPreferenceRow('Scalp Treatment', 'Botanical Detox Acupressure'),
                        const Divider(height: 18),
                        _buildPreferenceRow('Preferred Branch', 'VIORA â€¢ Khar West Flagship'),
                        const Divider(height: 18),
                        _buildPreferenceRow('Lead Master Stylist', 'Christian Dior (Art Director)'),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed('/beauty_quiz'),
                            icon: const Icon(Icons.auto_awesome_outlined, size: 16),
                            label: const Text('RETAKE CONSULTATION QUIZ', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed('/quiz_results'),
                            icon: const Icon(Icons.stars_outlined, size: 16, color: AppColors.primary),
                            label: const Text('VIEW SIGNATURE RECOMMENDATIONS', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 2: Quick Links
                  Text(
                    'ATELIER SERVICES & RESERVATIONS',
                    style: AppTextStyles.labelStyle.copyWith(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildNavigationTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'My Appointments & Reservations',
                    subtitle: 'Manage upcoming sessions and past treatments',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => const MyAppointmentsScreen())),
                  ),
                  _buildNavigationTile(
                    icon: Icons.spa_outlined,
                    title: 'Explore Service Catalogue',
                    subtitle: 'View haircutting, couture coloring, and spa services',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => const ServicesCategoriesScreen())),
                  ),

                  const SizedBox(height: 24),

                  // Section 3: Notification Preferences
                  Text(
                    'COMMUNICATION PREFERENCES',
                    style: AppTextStyles.labelStyle.copyWith(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('SMS Appointment Reminders', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: const Text('Receive reservation updates on mobile', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                            activeTrackColor: AppColors.primaryLight,
                            value: _smsReminders,
                            onChanged: (val) => setState(() => _smsReminders = val),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('VIP Atelier Invitations', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: const Text('Invites to private styling & preview masterclasses', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                            activeTrackColor: AppColors.primaryLight,
                            value: _vipInvitations,
                            onChanged: (val) => setState(() => _vipInvitations = val),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Seasonal Style Forecasts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: const Text('Curated trends from Parisian and Milan runways', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                            activeTrackColor: AppColors.primaryLight,
                            value: _styleForecasts,
                            onChanged: (val) => setState(() => _styleForecasts = val),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () async {
                        if (isLoggedIn) {
                          await FirebaseManager().auth.signOut();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.textPrimary,
                                content: Text('Signed out successfully.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                          }
                        } else {
                          Navigator.of(context).pushNamed('/login');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isLoggedIn ? const Color(0xFFD9534F) : AppColors.primary,
                        side: BorderSide(color: isLoggedIn ? const Color(0xFFD9534F) : AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Text(
                        isLoggedIn ? 'SIGN OUT' : 'SIGN IN / REGISTER',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreferenceRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

