class InspirationLook {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String description;
  final List<String> tags;
  final int likesCount;
  final double rating;
  final String? stylistName;
  final String? serviceName;

  const InspirationLook({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.description,
    this.tags = const [],
    this.likesCount = 0,
    this.rating = 5.0,
    this.stylistName,
    this.serviceName,
  });

  factory InspirationLook.fromJson(Map<String, dynamic> json) {
    return InspirationLook(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? 'Signature Look',
      category: json['category'] ?? 'Hair',
      imageUrl: json['imageUrl'] ?? 'assets/images/hair_cut_styling.png',
      description: json['description'] ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      stylistName: json['stylistName'],
      serviceName: json['serviceName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'imageUrl': imageUrl,
      'description': description,
      'tags': tags,
      'likesCount': likesCount,
      'rating': rating,
      'stylistName': stylistName,
      'serviceName': serviceName,
    };
  }

  static const List<InspirationLook> sampleLooks = [
    InspirationLook(
      id: 'look-balayage-01',
      title: 'Artisan French Balayage',
      category: 'Hair',
      imageUrl: 'assets/images/hair_colour.png',
      description: 'Hand-painted dimensional caramel ribbons blended seamlessly into natural brunette roots for an effortless glow.',
      tags: ['Balayage', 'Brunette', 'Sun-Kissed', 'Luxury'],
      likesCount: 342,
      rating: 4.95,
      stylistName: 'Julian Vance',
      serviceName: 'Artisan French Balayage',
    ),
    InspirationLook(
      id: 'look-hydra-02',
      title: 'Glass Skin Hydrafacial Glow',
      category: 'Skin',
      imageUrl: 'assets/images/service_facial.png',
      description: 'Medical-grade multi-step rejuvenation delivering deep extraction, peptide infusion, and luminous hydration.',
      tags: ['Hydrafacial', 'Glow', 'Peptides', 'Detox'],
      likesCount: 289,
      rating: 4.98,
      stylistName: 'Sarah Kothari',
      serviceName: 'Glow Hydrafacial',
    ),
    InspirationLook(
      id: 'look-cateye-03',
      title: 'Brown Ombre Velvet Cat Eye',
      category: 'Nails',
      imageUrl: 'assets/images/nail_brown_cat_eye.png',
      description: 'Magnetic shimmer shifting across deep mocha and hazelnut gradients with ultra-gloss gel finish.',
      tags: ['Cat Eye', 'Velvet', 'Mocha', 'Gel'],
      likesCount: 412,
      rating: 4.90,
      stylistName: 'Jessica Alba',
      serviceName: 'Brown Ombre Cat Eye',
    ),
    InspirationLook(
      id: 'look-layered-04',
      title: 'Airy 90s Butterfly Layer Cut',
      category: 'Hair',
      imageUrl: 'assets/images/hair_cut_styling.png',
      description: 'Feathered face-framing layers providing dynamic volume and airy natural bounce.',
      tags: ['Layers', 'Butterfly Cut', 'Volume', 'Styling'],
      likesCount: 512,
      rating: 4.92,
      stylistName: 'Christian Dior',
      serviceName: 'Layer Cut',
    ),
    InspirationLook(
      id: 'look-editorial-05',
      title: 'Runway Sculpted Brow & Lash',
      category: 'Brows & Lashes',
      imageUrl: 'assets/images/service_brows.png',
      description: 'Lamination, tinting, and micro-feathering paired with weightless silk lash extensions.',
      tags: ['Brows', 'Lamination', 'Lashes', 'Sculpt'],
      likesCount: 198,
      rating: 4.88,
      stylistName: 'Aria Montgomery',
      serviceName: 'Lash & Brow Luxury',
    ),
  ];
}

class InspirationResponse {
  final String id;
  final String requestId;
  final String stylistId;
  final String stylistName;
  final String? stylistAvatar;
  final String proposalNotes;
  final double estimatedCost;
  final int estimatedDurationMinutes;
  final String? suggestedModifications;
  final List<String> portfolioExamples;
  final String status;
  final DateTime createdAt;

  const InspirationResponse({
    required this.id,
    required this.requestId,
    required this.stylistId,
    required this.stylistName,
    this.stylistAvatar,
    required this.proposalNotes,
    required this.estimatedCost,
    required this.estimatedDurationMinutes,
    this.suggestedModifications,
    this.portfolioExamples = const [],
    this.status = 'pending',
    required this.createdAt,
  });

  factory InspirationResponse.fromJson(Map<String, dynamic> json) {
    return InspirationResponse(
      id: json['id']?.toString() ?? json['responseId'] ?? json['_id']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? '',
      stylistId: json['stylistId']?.toString() ?? '',
      stylistName: json['stylistName'] ?? 'VIORA Master Stylist',
      stylistAvatar: json['stylistAvatar'],
      proposalNotes: json['proposalNotes'] ?? '',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 60,
      suggestedModifications: json['suggestedModifications'],
      portfolioExamples: (json['portfolioExamples'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'stylistAvatar': stylistAvatar,
      'proposalNotes': proposalNotes,
      'estimatedCost': estimatedCost,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'suggestedModifications': suggestedModifications,
      'portfolioExamples': portfolioExamples,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class InspirationRequest {
  final String id;
  final String customerId;
  final String? customerName;
  final String imageUrl;
  final String description;
  final String category;
  final String? preferredBranchId;
  final String? budgetRange;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final List<InspirationResponse> responses;

  const InspirationRequest({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.imageUrl,
    required this.description,
    required this.category,
    this.preferredBranchId,
    this.budgetRange,
    this.notes,
    this.status = 'pending',
    required this.createdAt,
    this.responses = const [],
  });

  String get referenceImageUrl => imageUrl;
  String get consultationGoals => description.isNotEmpty ? description : (notes ?? 'Bespoke consultation request');
  String get preferredBranch => preferredBranchId ?? 'Flagship Khar West';

  factory InspirationRequest.fromJson(Map<String, dynamic> json) {
    return InspirationRequest(
      id: json['id']?.toString() ?? json['requestId'] ?? json['_id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName'],
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Hair',
      preferredBranchId: json['preferredBranchId'],
      budgetRange: json['budgetRange'],
      notes: json['notes'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      responses: (json['responses'] as List<dynamic>?)
              ?.map((e) => InspirationResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'preferredBranchId': preferredBranchId,
      'budgetRange': budgetRange,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'responses': responses.map((r) => r.toJson()).toList(),
    };
  }
}
