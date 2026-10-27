import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/stylist.dart';
import '../core/firebase/firebase_manager.dart';
import 'booking_confirmed_screen.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final Stylist stylist;
  final String lookName;
  final int finalPrice;
  final Map<String, dynamic>? customizations;

  const DateTimeSelectionScreen({
    super.key,
    required this.stylist,
    this.lookName = 'Brown Ombre Cat Eye Nails',
    this.finalPrice = 2600,
    this.customizations,
  });

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  // Wed 17 is preselected as per screenshot
  int _selectedDayIndex = 2; // Wed 17
  String _selectedSlot = '11:30 AM'; // 11:30 AM preselected
  String _selectedPeriod = 'All'; // 'All', 'Morning', 'Afternoon', 'Evening'

  final List<Map<String, String>> _dates = const [
    {'day': 'Mon', 'date': '15'},
    {'day': 'Tue', 'date': '16'},
    {'day': 'Wed', 'date': '17'},
    {'day': 'Thu', 'date': '18'},
    {'day': 'Fri', 'date': '19'},
    {'day': 'Sat', 'date': '20'},
  ];

  final List<String> _slots = const [
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '01:30 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:30 PM',
    '06:30 PM',
    '07:30 PM',
  ];

  List<String> get _filteredSlots {
    if (_selectedPeriod == 'Morning') {
      return _slots.where((s) => s.contains('AM')).toList();
    } else if (_selectedPeriod == 'Afternoon') {
      return _slots.where((s) {
        if (!s.contains('PM')) return false;
        final hour = int.tryParse(s.split(':')[0]) ?? 0;
        return hour == 12 || hour < 5;
      }).toList();
    } else if (_selectedPeriod == 'Evening') {
      return _slots.where((s) {
        if (!s.contains('PM')) return false;
        final hour = int.tryParse(s.split(':')[0]) ?? 0;
        return hour >= 5 && hour != 12;
      }).toList();
    }
    return _slots;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _dates[_selectedDayIndex];
    final dateDisplayString = '${selectedDate['day']}, ${selectedDate['date']} Oct';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
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
                      'Select Date & Time',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.editorialTitle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month & Year Row with Navigation Chevrons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'October 2023',
                          style: AppTextStyles.editorialTitle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Row(
                          children: [
                            _buildMonthNavButton(Icons.chevron_left_rounded),
                            const SizedBox(width: 8),
                            _buildMonthNavButton(Icons.chevron_right_rounded),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Horizontal Dates Row
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: List.generate(_dates.length, (index) {
                          final item = _dates[index];
                          final isSelected = index == _selectedDayIndex;

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedDayIndex = index),
                              child: Container(
                                width: 48,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 1.2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item['day']!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.9)
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['date']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Available Slots Heading
                    const Text(
                      'AVAILABLE SLOTS',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF6E6A66),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Morning / Afternoon / Evening Period Filter Chips
                    Row(
                      children: ['All', 'Morning', 'Afternoon', 'Evening'].map((period) {
                        final isSelected = _selectedPeriod == period;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPeriod = period),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                period,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // 3-Column Time Slots Grid
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _filteredSlots.map((slot) {
                        final isSelected = slot == _selectedSlot;
                        // Calculate width for 3 items per row with 12px spacing: (screenWidth - 40 - 24) / 3
                        final itemWidth =
                            (MediaQuery.of(context).size.width - 40 - 24) / 3;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedSlot = slot),
                          child: Container(
                            width: itemWidth,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF7EFE8)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Summary Bar & Action Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Summary Row
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 1.2,
                          ),
                        ),
                        child: ClipOval(
                          child: widget.stylist.imagePath.isNotEmpty
                              ? Image.asset(
                                  widget.stylist.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person,
                                          color: AppColors.primary),
                                )
                              : const Icon(Icons.auto_awesome,
                                  color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.lookName,
                              style: AppTextStyles.editorialTitle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'with ${widget.stylist.name}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${widget.finalPrice}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // BOOK APPOINTMENT Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseManager().auth.currentUser;
                        final branch = widget.customizations?['branch'] as String? ?? 'Model Town';
                        final category = widget.customizations?['category'] as String? ?? 'Hair Cut & Styling';

                        await FirebaseManager().firestore.createAppointment(
                          customerId: user?.uid ?? 'guest_client',
                          customerName: user?.name ?? 'Sarah Thomas',
                          serviceTitle: widget.lookName,
                          category: category,
                          stylistName: widget.stylist.name,
                          stylistRole: widget.stylist.role,
                          stylistAvatar: widget.stylist.avatarUrl.isNotEmpty
                              ? widget.stylist.avatarUrl
                              : 'assets/images/avatar_christian_dior.png',
                          appointmentDate: DateTime.now().add(Duration(days: _selectedDayIndex)),
                          timeSlot: _selectedSlot,
                          totalPrice: widget.finalPrice,
                          salonBranch: branch,
                        );

                        if (!context.mounted) return;

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookingConfirmedScreen(
                              stylist: widget.stylist,
                              lookName: widget.lookName,
                              finalPrice: widget.finalPrice,
                              selectedDateString: dateDisplayString,
                              selectedTimeString: _selectedSlot,
                              branchName: branch,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text(
                        'BOOK APPOINTMENT',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
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

  Widget _buildMonthNavButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Icon(
        icon,
        size: 18,
        color: AppColors.textPrimary,
      ),
    );
  }
}