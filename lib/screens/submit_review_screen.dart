import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class SubmitReviewScreen extends StatefulWidget {
  final String? appointmentId;
  final String? stylistId;
  final String? stylistName;
  final String? serviceName;

  const SubmitReviewScreen({
    super.key,
    this.appointmentId,
    this.stylistId,
    this.stylistName,
    this.serviceName,
  });

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentsController = TextEditingController();

  double _overallRating = 5.0;
  double _lookRating = 5.0;
  double _stylistRating = 5.0;

  String? _selectedAppointmentId;
  String? _selectedStylistId;
  String? _selectedServiceName;
  List<EligibleAppointment> _eligibleAppointments = [];
  bool _isLoadingEligible = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedAppointmentId = widget.appointmentId;
    _selectedStylistId = widget.stylistId ?? 's1';
    _selectedServiceName = widget.serviceName ?? 'Artisan French Balayage';

    if (_selectedAppointmentId == null) {
      _loadEligibleAppointments();
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadEligibleAppointments() async {
    setState(() => _isLoadingEligible = true);
    final list = await _reviewService.getEligibleAppointments();
    if (mounted) {
      setState(() {
        _eligibleAppointments = list;
        if (list.isNotEmpty && _selectedAppointmentId == null) {
          _selectedAppointmentId = list.first.appointmentId;
          _selectedStylistId = list.first.stylistId;
          _selectedServiceName = list.first.serviceName;
        }
        _isLoadingEligible = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAppointmentId == null) {
      setState(() => _errorMessage = 'Please select a completed appointment to review.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _reviewService.submitReview(
        appointmentId: _selectedAppointmentId!,
        stylistId: _selectedStylistId ?? 's1',
        rating: _overallRating,
        lookRating: _lookRating,
        stylistRating: _stylistRating,
        comments: _commentsController.text.trim(),
        serviceName: _selectedServiceName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your atelier review has been recorded.'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isSubmitting = false;
        });
      }
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
          'SHARE YOUR EXPERIENCE',
          style: AppTextStyles.uppercaseSubtitle(fontSize: 13, letterSpacing: 2.2).copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rate Your Atelier Visit',
                style: AppTextStyles.editorialTitle(fontSize: 22),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your refined feedback helps us uphold our meticulous craft standards and guides fellow clients in their beauty journeys.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_isLoadingEligible)
                const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: AppColors.primary)))
              else if (widget.appointmentId == null && _eligibleAppointments.isNotEmpty) ...[
                Text(
                  'COMPLETED TREATMENT',
                  style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.8),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedAppointmentId,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: _eligibleAppointments.map((app) {
                    return DropdownMenuItem(
                      value: app.appointmentId,
                      child: Text('${app.serviceName} (${app.stylistName})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final chosen = _eligibleAppointments.firstWhere((a) => a.appointmentId == val);
                      setState(() {
                        _selectedAppointmentId = val;
                        _selectedStylistId = chosen.stylistId;
                        _selectedServiceName = chosen.serviceName;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Star Rating Section 1: Overall Experience
              _buildRatingCard(
                title: 'OVERALL ATELIER EXPERIENCE',
                subtitle: 'Atmosphere, courtesy, and overall hospitality',
                rating: _overallRating,
                onChanged: (val) => setState(() => _overallRating = val),
              ),
              const SizedBox(height: 16),

              // Star Rating Section 2: Look / Transformation
              _buildRatingCard(
                title: 'LOOK & DESIGN RESULT',
                subtitle: 'Aesthetic execution, precision, and longevity',
                rating: _lookRating,
                onChanged: (val) => setState(() => _lookRating = val),
              ),
              const SizedBox(height: 16),

              // Star Rating Section 3: Stylist Expertise
              _buildRatingCard(
                title: 'STYLIST EXPERTISE & ATTENTION',
                subtitle: 'Technique, consultation depth, and styling guidance',
                rating: _stylistRating,
                onChanged: (val) => setState(() => _stylistRating = val),
              ),
              const SizedBox(height: 24),

              // Comments Field
              Text(
                'YOUR THOUGHTS & ATELIER NOTES *',
                style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.8),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentsController,
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please provide your honest reflections';
                  if (v.trim().length < 10) return 'Please share at least a few words (min 10 characters)';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Share what you loved about the technique, consultation, or atmosphere...',
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : _submitReview,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'POST VERIFIED ATELIER REVIEW',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingCard({
    required String title,
    required String subtitle,
    required double rating,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
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
                title,
                style: AppTextStyles.uppercaseSubtitle(fontSize: 10.5, letterSpacing: 1.4),
              ),
              Text(
                '${rating.toStringAsFixed(1)} ★',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNum = index + 1;
              final isFilled = rating >= starNum;
              return IconButton(
                iconSize: 32,
                icon: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  color: isFilled ? const Color(0xFFFFB300) : AppColors.border,
                ),
                onPressed: () => onChanged(starNum.toDouble()),
              );
            }),
          ),
        ],
      ),
    );
  }
}


