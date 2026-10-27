import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/inspiration_model.dart';
import '../services/inspiration_service.dart';
import 'branches_list_screen.dart';

class InspirationResponsesScreen extends StatefulWidget {
  final String? requestId;
  const InspirationResponsesScreen({super.key, this.requestId});

  @override
  State<InspirationResponsesScreen> createState() => _InspirationResponsesScreenState();
}

class _InspirationResponsesScreenState extends State<InspirationResponsesScreen> {
  final InspirationService _inspirationService = InspirationService();
  List<InspirationRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final list = await _inspirationService.getRequests();
    if (mounted) {
      setState(() {
        _requests = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _onChooseStylist(InspirationRequest request, InspirationResponse response) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Confirm Stylist Selection',
          style: AppTextStyles.editorialTitle(fontSize: 18),
        ),
        content: Text(
          'Select ${response.stylistName} for this consultation? Their estimated fee of ₹${response.estimatedCost.toInt()} will be reserved for your session.',
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _inspirationService.chooseStylist(request.id, response.id);
      await _inspirationService.getBookingHandoffContext(request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stylist ${response.stylistName} selected! Proceeding to atelier booking.'),
            backgroundColor: AppColors.primary,
          ),
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BranchesListScreen(
              selectedCategory: request.category,
            ),
          ),
        );
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
          'MY REQUESTS & PROPOSALS',
          style: AppTextStyles.uppercaseSubtitle(fontSize: 13, letterSpacing: 2.2).copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _requests.isEmpty
              ? _buildEmptyView()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    return _buildRequestCard(req);
                  },
                ),
    );
  }

  Widget _buildRequestCard(InspirationRequest request) {
    final statusColor = request.status == 'accepted'
        ? Colors.green
        : request.status == 'responded'
            ? AppColors.primary
            : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  request.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          request.category.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            request.status.toUpperCase(),
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Proposals section
          if (request.responses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Waiting for master stylists to review and submit consultation proposals...',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
            )
          else ...[
            Text(
              'STYLIST PROPOSALS (${request.responses.length})',
              style: AppTextStyles.uppercaseSubtitle(fontSize: 10.5, letterSpacing: 1.5),
            ),
            const SizedBox(height: 10),
            Column(
              children: request.responses.map((resp) {
                return _buildResponseProposalCard(request, resp);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResponseProposalCard(InspirationRequest request, InspirationResponse response) {
    final isAccepted = response.status == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAccepted ? AppColors.primaryLight : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAccepted ? AppColors.primary : AppColors.border,
          width: isAccepted ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  response.stylistAvatar ?? 'assets/images/avatar_christian.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      response.stylistName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Est. ${response.estimatedDurationMinutes} mins • ₹${response.estimatedCost.toInt()}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              if (isAccepted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'CHOSEN',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                )
              else if (request.status != 'accepted')
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _onChooseStylist(request, response),
                  child: const Text('CHOOSE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            response.proposalNotes,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, height: 1.4),
          ),
          if (response.suggestedModifications != null) ...[
            const SizedBox(height: 4),
            Text(
              'Recommendation: ${response.suggestedModifications}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_chat_read_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(
              'No Inspiration Requests Yet',
              style: AppTextStyles.editorialTitle(fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'You have not submitted any visual consultation requests. Explore the atelier gallery and tap "Request Bespoke Look".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

