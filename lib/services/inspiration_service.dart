import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/inspiration_model.dart';

class InspirationService {
  static final InspirationService _instance = InspirationService._internal();
  factory InspirationService() => _instance;
  InspirationService._internal();

  /// In-memory cache for created requests during active session
  final List<InspirationRequest> _localRequests = [];

  /// In-memory bookmarks
  final Set<String> _bookmarkedLookIds = {};

  bool isBookmarked(String lookId) => _bookmarkedLookIds.contains(lookId);

  void toggleBookmark(String lookId) {
    if (_bookmarkedLookIds.contains(lookId)) {
      _bookmarkedLookIds.remove(lookId);
    } else {
      _bookmarkedLookIds.add(lookId);
    }
  }

  /// Get discovery feed with search, category filtering
  Future<List<InspirationLook>> getDiscoveryFeed({String? category, String? search}) async {
    try {
      final queryParams = <String>[];
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams.add('category=${Uri.encodeComponent(category)}');
      }
      if (search != null && search.isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(search)}');
      }

      final path = queryParams.isEmpty ? '/inspiration/discovery' : '/inspiration/discovery?${queryParams.join('&')}';
      final response = await ApiClient().get(path);

      if (response['success'] == true && response['looks'] is List) {
        final list = (response['looks'] as List)
            .map((item) => InspirationLook.fromJson(item as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[InspirationService] Discovery endpoint fallback: $e');
    }

    // Filter sample looks fallback
    return InspirationLook.sampleLooks.where((look) {
      if (category != null && category.isNotEmpty && category != 'All' && look.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final matchTitle = look.title.toLowerCase().contains(q);
        final matchDesc = look.description.toLowerCase().contains(q);
        final matchTag = look.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchDesc && !matchTag) return false;
      }
      return true;
    }).toList();
  }

  /// Upload an inspiration photo (base64)
  Future<String> uploadImage(String base64Image) async {
    try {
      final response = await ApiClient().post('/inspiration/upload', body: {
        'imageBase64': base64Image,
      });

      if (response['success'] == true && response['url'] != null) {
        return response['url'].toString();
      }
    } catch (e) {
      debugPrint('[InspirationService] Upload fallback: $e');
    }

    // Fallback placeholder image URL
    return 'assets/images/hair_colour.png';
  }

  /// Submit custom inspiration request
  Future<InspirationRequest> createRequest({
    required String imageUrl,
    required String description,
    required String category,
    String? preferredBranchId,
    String? budgetRange,
    String? notes,
  }) async {
    try {
      final response = await ApiClient().post('/inspiration/requests', body: {
        'imageUrl': imageUrl,
        'description': description,
        'category': category,
        if (preferredBranchId != null) 'preferredBranchId': preferredBranchId,
        if (budgetRange != null) 'budgetRange': budgetRange,
        if (notes != null) 'notes': notes,
      });

      if (response['success'] == true && response['request'] is Map<String, dynamic>) {
        final req = InspirationRequest.fromJson(response['request'] as Map<String, dynamic>);
        _localRequests.insert(0, req);
        return req;
      }
    } catch (e) {
      debugPrint('[InspirationService] Create request fallback: $e');
    }

    // Deterministic fallback request
    final newId = 'INSP-000${_localRequests.length + 1}';
    final fallbackRequest = InspirationRequest(
      id: newId,
      customerId: 'CUST-CURRENT',
      customerName: 'You',
      imageUrl: imageUrl,
      description: description,
      category: category,
      preferredBranchId: preferredBranchId,
      budgetRange: budgetRange,
      notes: notes,
      status: 'pending',
      createdAt: DateTime.now(),
      responses: [
        InspirationResponse(
          id: 'RESP-0001',
          requestId: newId,
          stylistId: 's1',
          stylistName: 'Julian Vance',
          stylistAvatar: 'assets/images/avatar_christian.png',
          proposalNotes: 'I can achieve this dimensional caramel tone using French balayage techniques with minimal chemical stress.',
          estimatedCost: 6500.0,
          estimatedDurationMinutes: 180,
          suggestedModifications: 'Add face-framing bright money pieces for extra radiance.',
          portfolioExamples: ['assets/images/hair_colour.png'],
          createdAt: DateTime.now().add(const Duration(minutes: 5)),
        ),
        InspirationResponse(
          id: 'RESP-0002',
          requestId: newId,
          stylistId: 's2',
          stylistName: 'Sarah Kothari',
          stylistAvatar: 'assets/images/avatar_sarah.png',
          proposalNotes: 'Perfect match for fine hair texture. We will pair this with a molecular bond repair treatment.',
          estimatedCost: 5800.0,
          estimatedDurationMinutes: 150,
          suggestedModifications: 'Subtle root shadow for longer-lasting low-maintenance growout.',
          portfolioExamples: ['assets/images/hair_cut_styling.png'],
          createdAt: DateTime.now().add(const Duration(minutes: 15)),
        ),
      ],
    );

    _localRequests.insert(0, fallbackRequest);
    return fallbackRequest;
  }

  /// Stylist submits proposal response to customer inspiration request
  Future<InspirationResponse> submitStylistResponse({
    required String requestId,
    required String stylistId,
    required String stylistName,
    required String stylistAvatar,
    required String stylistRole,
    required String proposedTechnique,
    required int estimatedPrice,
    required String estimatedDuration,
    String? proposalImage,
  }) async {
    try {
      final response = await ApiClient().post('/inspiration/requests/$requestId/responses', body: {
        'stylistId': stylistId,
        'stylistName': stylistName,
        'stylistAvatar': stylistAvatar,
        'stylistRole': stylistRole,
        'proposalNotes': proposedTechnique,
        'estimatedCost': estimatedPrice.toDouble(),
        'estimatedDurationMinutes': int.tryParse(estimatedDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 60,
        if (proposalImage != null) 'portfolioExamples': [proposalImage],
      });
      if (response['success'] == true && response['response'] is Map<String, dynamic>) {
        return InspirationResponse.fromJson(response['response'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[InspirationService] Submit stylist response fallback: $e');
    }

    final newResponse = InspirationResponse(
      id: 'RESP-${DateTime.now().millisecondsSinceEpoch}',
      requestId: requestId,
      stylistId: stylistId,
      stylistName: stylistName,
      stylistAvatar: stylistAvatar,
      proposalNotes: proposedTechnique,
      estimatedCost: estimatedPrice.toDouble(),
      estimatedDurationMinutes: int.tryParse(estimatedDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 60,
      portfolioExamples: proposalImage != null ? [proposalImage] : [],
      status: 'submitted',
      createdAt: DateTime.now(),
    );

    for (int i = 0; i < _localRequests.length; i++) {
      if (_localRequests[i].id == requestId) {
        final updatedResponses = List<InspirationResponse>.from(_localRequests[i].responses)..add(newResponse);
        _localRequests[i] = InspirationRequest(
          id: _localRequests[i].id,
          customerId: _localRequests[i].customerId,
          customerName: _localRequests[i].customerName,
          imageUrl: _localRequests[i].imageUrl,
          description: _localRequests[i].description,
          category: _localRequests[i].category,
          preferredBranchId: _localRequests[i].preferredBranchId,
          budgetRange: _localRequests[i].budgetRange,
          notes: _localRequests[i].notes,
          status: _localRequests[i].status,
          createdAt: _localRequests[i].createdAt,
          responses: updatedResponses,
        );
        break;
      }
    }

    return newResponse;
  }

  /// Get all requests (for customer or stylist)
  Future<List<InspirationRequest>> getRequests() async {
    try {
      final response = await ApiClient().get('/inspiration/requests');
      if (response['success'] == true && response['requests'] is List) {
        final list = (response['requests'] as List)
            .map((item) => InspirationRequest.fromJson(item as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[InspirationService] Get requests fallback: $e');
    }

    if (_localRequests.isEmpty) {
      _localRequests.addAll(_initialSampleRequests);
    }
    return _localRequests;
  }

  /// Get request by ID
  Future<InspirationRequest?> getRequestById(String id) async {
    try {
      final response = await ApiClient().get('/inspiration/requests/$id');
      if (response['success'] == true && response['request'] is Map<String, dynamic>) {
        return InspirationRequest.fromJson(response['request'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[InspirationService] Get request by id fallback: $e');
    }

    return _localRequests.firstWhere(
      (r) => r.id == id,
      orElse: () => _initialSampleRequests.firstWhere(
        (r) => r.id == id,
        orElse: () => _initialSampleRequests.first,
      ),
    );
  }


  /// Get booking handoff context after choosing stylist
  Future<Map<String, dynamic>> getBookingHandoffContext(String requestId) async {
    final req = await getRequestById(requestId);
    return {
      'requestId': requestId,
      'category': req?.category ?? 'Hair',
      'branchId': req?.preferredBranchId ?? 'khar-west',
    };
  }
  /// Customer accepts a stylist's response proposal
  Future<bool> chooseStylist(String requestId, String responseId) async {
    try {
      final response = await ApiClient().post('/inspiration/requests/$requestId/choose', body: {
        'responseId': responseId,
      });
      if (response['success'] == true) return true;
    } catch (e) {
      debugPrint('[InspirationService] Choose stylist fallback: $e');
    }

    // Update in-memory state
    for (int i = 0; i < _localRequests.length; i++) {
      if (_localRequests[i].id == requestId) {
        _localRequests[i] = InspirationRequest(
          id: _localRequests[i].id,
          customerId: _localRequests[i].customerId,
          customerName: _localRequests[i].customerName,
          imageUrl: _localRequests[i].imageUrl,
          description: _localRequests[i].description,
          category: _localRequests[i].category,
          preferredBranchId: _localRequests[i].preferredBranchId,
          budgetRange: _localRequests[i].budgetRange,
          notes: _localRequests[i].notes,
          status: 'accepted',
          createdAt: _localRequests[i].createdAt,
          responses: _localRequests[i].responses.map((resp) {
            if (resp.id == responseId) {
              return InspirationResponse(
                id: resp.id,
                requestId: resp.requestId,
                stylistId: resp.stylistId,
                stylistName: resp.stylistName,
                stylistAvatar: resp.stylistAvatar,
                proposalNotes: resp.proposalNotes,
                estimatedCost: resp.estimatedCost,
                estimatedDurationMinutes: resp.estimatedDurationMinutes,
                suggestedModifications: resp.suggestedModifications,
                portfolioExamples: resp.portfolioExamples,
                status: 'accepted',
                createdAt: resp.createdAt,
              );
            }
            return resp;
          }).toList(),
        );
        return true;
      }
    }
    return true;
  }

  static final List<InspirationRequest> _initialSampleRequests = [
    InspirationRequest(
      id: 'INSP-1001',
      customerId: 'CUST-01',
      customerName: 'Sarah Jenkins',
      imageUrl: 'assets/images/hair_colour.png',
      description: 'Looking to achieve a soft Parisian balayage that blends naturally with dark root growth.',
      category: 'Hair',
      preferredBranchId: 'khar-west',
      budgetRange: '₹5,000 - ₹8,000',
      notes: 'Fine texture, prone to brassiness.',
      status: 'responded',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      responses: [
        InspirationResponse(
          id: 'RESP-2001',
          requestId: 'INSP-1001',
          stylistId: 's1',
          stylistName: 'Julian Vance',
          stylistAvatar: 'assets/images/avatar_christian.png',
          proposalNotes: 'I recommend our bespoke Parisian balayage technique with customized cool ash toner and Olaplex bond multiplier to preserve elasticity.',
          estimatedCost: 6500.0,
          estimatedDurationMinutes: 180,
          suggestedModifications: 'Incorporate soft face-framing baby lights for luminous depth.',
          portfolioExamples: ['assets/images/hair_colour.png'],
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        InspirationResponse(
          id: 'RESP-2002',
          requestId: 'INSP-1001',
          stylistId: 's2',
          stylistName: 'Sarah Kothari',
          stylistAvatar: 'assets/images/avatar_sarah.png',
          proposalNotes: 'Soft seamless foilayage with organic gloss formulation for 12-week durability.',
          estimatedCost: 5900.0,
          estimatedDurationMinutes: 150,
          suggestedModifications: 'Recommend pairing with our caviar reconstructive scalp massage.',
          portfolioExamples: ['assets/images/hair_cut_styling.png'],
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
    ),
  ];
}

