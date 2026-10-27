import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'home_screen.dart';
import 'branches_list_screen.dart';
import 'my_appointments_screen.dart';
import 'customer_profile_screen.dart';

/// Persistent Navigation Shell for VIORA Luxury Customer Experience
/// Hosts the 4 primary core destinations specified by the design references:
/// - Tab 0: Home (Group 29.png)
/// - Tab 1: Salons (Group 39.png)
/// - Tab 2: Bookings (Group 37.png)
/// - Tab 3: Profile (Group 50.png)
class CustomerMainScaffold extends StatefulWidget {
  final int initialIndex;

  const CustomerMainScaffold({
    super.key,
    this.initialIndex = 0,
  });

  static _CustomerMainScaffoldState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CustomerMainScaffoldState>();
  }

  static void switchTab(BuildContext context, int index) {
    final state = of(context);
    if (state != null) {
      state.setIndex(index);
    }
  }

  @override
  State<CustomerMainScaffold> createState() => _CustomerMainScaffoldState();
}

class _CustomerMainScaffoldState extends State<CustomerMainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    if (_currentIndex != index && mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          BranchesListScreen(isTab: true),
          MyAppointmentsScreen(isTab: true),
          CustomerProfileScreen(isTab: true),
        ],
      ),
      bottomNavigationBar: _buildLuxuryBottomNav(context),
    );
  }

  Widget _buildLuxuryBottomNav(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: 0.9,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 6, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          _buildNavItem(
            index: 1,
            label: 'Salons',
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront,
          ),
          _buildNavItem(
            index: 2,
            label: 'Bookings',
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today,
          ),
          _buildNavItem(
            index: 3,
            label: 'Profile',
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _currentIndex == index;
    const activeColor = AppColors.primary;
    const inactiveColor = Color(0xFF8A847C);

    return Expanded(
      child: InkWell(
        onTap: () => setIndex(index),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey<bool>(isSelected),
                  color: isSelected ? activeColor : inactiveColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.4,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
