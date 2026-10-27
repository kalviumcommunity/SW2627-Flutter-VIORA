import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/inspiration_model.dart';
import '../models/salon_branch.dart';
import '../services/inspiration_service.dart';

class InspirationRequestScreen extends StatefulWidget {
  final String? initialCategory;
  final InspirationLook? prefilledLook;

  const InspirationRequestScreen({
    super.key,
    this.initialCategory,
    this.prefilledLook,
  });

  @override
  State<InspirationRequestScreen> createState() => _InspirationRequestScreenState();
}

class _InspirationRequestScreenState extends State<InspirationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final InspirationService _inspirationService = InspirationService();

  late String _selectedCategory;
  String _selectedBranchId = 'khar-west';
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController(text: '₹5,000 - ₹8,000');
  final TextEditingController _notesController = TextEditingController();

  String _selectedImage = 'assets/images/hair_colour.png';
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _categories = ['Hair', 'Skin', 'Nails', 'Brows & Lashes', 'Makeup'];

  final List<Map<String, String>> _sampleImages = [
    {'title': 'Balayage Glow', 'path': 'assets/images/hair_colour.png'},
    {'title': 'Butterfly Layers', 'path': 'assets/images/hair_cut_styling.png'},
    {'title': 'Hydrafacial Glass', 'path': 'assets/images/service_facial.png'},
    {'title': 'Cat Eye Nails', 'path': 'assets/images/nail_brown_cat_eye.png'},
    {'title': 'Editorial Lashes', 'path': 'assets/images/service_brows.png'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.prefilledLook?.category ?? widget.initialCategory ?? 'Hair';
    if (widget.prefilledLook != null) {
      _selectedImage = widget.prefilledLook!.imageUrl;
      _descController.text = 'Inspired by ${widget.prefilledLook!.title}: ${widget.prefilledLook!.description}';
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final req = await _inspirationService.createRequest(
        imageUrl: _selectedImage,
        description: _descController.text.trim(),
        category: _selectedCategory,
        preferredBranchId: _selectedBranchId,
        budgetRange: _budgetController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bespoke look request "${req.id}" submitted to master stylists!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to submit inspiration request: $e';
        });
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'BESPOKE CONSULTATION',
          style: AppTextStyles.uppercaseSubtitle(
            fontSize: 13,
            letterSpacing: 2.2,
          ).copyWith(fontWeight: FontWeight.w700),
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
                'Bring Your Vision',
                style: AppTextStyles.editorialTitle(fontSize: 22),
              ),
              const SizedBox(height: 6),
              const Text(
                'Upload or choose your reference aesthetic. Our resident master stylists will review your submission and reply with custom proposals and price estimates.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF98080)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFF9B1C1C), fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Visual Inspiration Selector
              Text(
                'REFERENCE VISUAL',
                style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.8),
              ),
              const SizedBox(height: 8),

              // Selected Image Preview
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  _selectedImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 48),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Sample Presets Carousel
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = _sampleImages[index];
                    final isSelected = _selectedImage == item['path'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedImage = item['path']!),
                      child: Container(
                        width: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          item['path']!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Category Selector
              Text(
                'SERVICE DOMAIN',
                style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.8),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                'CONSULTATION GOALS & DESIRED OUTCOME *',
                style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.8),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please describe your desired look or goals';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'e.g., Looking for seamless warm honey balayage that blends naturally with dark espresso roots...',
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
              const SizedBox(height: 20),

              // Preferred Branch
              Text(
                'PREFERRED SALON BRANCH',
                style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.8),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedBranchId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: SalonBranch.sampleBranches.map((b) {
                  final city = b.address.split(',').last.trim();
                  return DropdownMenuItem(
                    value: b.id,
                    child: Text('${b.name} ($city)'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBranchId = val);
                },
              ),
              const SizedBox(height: 20),

              // Target Budget
              Text(
                'TARGET BUDGET ESTIMATE',
                style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.8),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                decoration: InputDecoration(
                  hintText: 'e.g. ₹5,000 - ₹8,000',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Special Notes
              Text(
                'HAIR / SKIN PROFILE & SENSITIVITY NOTES',
                style: AppTextStyles.uppercaseSubtitle(fontSize: 11, letterSpacing: 1.8),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g., Previously colored 6 months ago, sensitive scalp, low porosity...',
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
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
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
                          'SUBMIT FOR STYLIST PROPOSALS',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

