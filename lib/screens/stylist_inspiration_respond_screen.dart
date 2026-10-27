import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/inspiration_model.dart';
import '../services/inspiration_service.dart';

class StylistInspirationRespondScreen extends StatefulWidget {
  final InspirationRequest request;
  final String stylistId;
  final String stylistName;
  final String stylistRole;
  final String stylistAvatar;

  const StylistInspirationRespondScreen({
    super.key,
    required this.request,
    this.stylistId = 's1',
    this.stylistName = 'Julian Vance',
    this.stylistRole = 'Art Director & Master Colorist',
    this.stylistAvatar = 'assets/images/stylist_julian.png',
  });

  @override
  State<StylistInspirationRespondScreen> createState() => _StylistInspirationRespondScreenState();
}

class _StylistInspirationRespondScreenState extends State<StylistInspirationRespondScreen> {
  final _formKey = GlobalKey<FormState>();
  final _techniqueController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController(text: '90 mins');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _techniqueController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final price = int.tryParse(_priceController.text.trim()) ?? 3500;

    try {
      await InspirationService().submitStylistResponse(
        requestId: widget.request.id,
        stylistId: widget.stylistId,
        stylistName: widget.stylistName,
        stylistAvatar: widget.stylistAvatar,
        stylistRole: widget.stylistRole,
        proposedTechnique: _techniqueController.text.trim(),
        estimatedPrice: price,
        estimatedDuration: _durationController.text.trim(),
        proposalImage: widget.request.referenceImageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Bespoke styling proposal dispatched to client!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFD9534F),
            content: Text('Submission failed: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Craft Bespoke Proposal',
          style: AppTextStyles.editorialTitle(fontSize: 20).copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Request Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CLIENT REQUEST',
                            style: AppTextStyles.uppercaseSubtitle(fontSize: 10, letterSpacing: 1.5),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.request.category,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.request.consultationGoals,
                        style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Preferred: ${widget.request.preferredBranch}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  'YOUR ATELIER PROPOSAL',
                  style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),

                // Proposed Technique Notes
                TextFormField(
                  controller: _techniqueController,
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Please outline your proposed technique (min 10 characters).'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Artistic Technique & Formula Notes *',
                    hintText: 'e.g., We will apply multidimensional balayage highlights using Olaplex bond multiplier, followed by a gloss toner for champagne reflections.',
                    fillColor: AppColors.surface,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),

                const SizedBox(height: 16),

                // Estimated Price
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please provide an estimated investment.';
                    if (int.tryParse(v.trim()) == null) return 'Must be a valid integer amount.';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Estimated Investment (₹) *',
                    hintText: '3500',
                    prefixText: '₹ ',
                    fillColor: AppColors.surface,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),

                const SizedBox(height: 16),

                // Estimated Duration
                TextFormField(
                  controller: _durationController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please specify expected session duration.' : null,
                  decoration: InputDecoration(
                    labelText: 'Session Duration *',
                    hintText: '90 mins',
                    fillColor: AppColors.surface,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitProposal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                          )
                        : const Text(
                            'DISPATCH PROPOSAL TO CLIENT',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, letterSpacing: 1.0),
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
}
