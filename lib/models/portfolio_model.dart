class PortfolioItem {
  final String id;
  final String stylistId;
  final String title;
  final String category;
  final String imageUrl;
  final String description;
  final List<String> tags;
  final String? serviceName;
  final int likesCount;
  final DateTime createdAt;

  const PortfolioItem({
    required this.id,
    required this.stylistId,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.description,
    this.tags = const [],
    this.serviceName,
    this.likesCount = 42,
    required this.createdAt,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id']?.toString() ?? json['itemId'] ?? json['_id']?.toString() ?? '',
      stylistId: json['stylistId']?.toString() ?? '',
      title: json['title'] ?? 'Signature Work',
      category: json['category'] ?? 'Hair',
      imageUrl: json['imageUrl'] ?? 'assets/images/hair_colour.png',
      description: json['description'] ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      serviceName: json['serviceName'],
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 42,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stylistId': stylistId,
      'title': title,
      'category': category,
      'imageUrl': imageUrl,
      'description': description,
      'tags': tags,
      'serviceName': serviceName,
      'likesCount': likesCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static final List<PortfolioItem> samplePortfolio = [
    PortfolioItem(
      id: 'port-01',
      stylistId: 's1',
      title: 'Caramel Sunkissed Balayage Melt',
      category: 'Coloring',
      imageUrl: 'assets/images/hair_colour.png',
      description: 'Hand-painted transition on virgin base using gentle clay lightener and Olaplex bond repair.',
      tags: ['Balayage', 'Caramel', 'Brunette', 'Dimensional'],
      serviceName: 'Artisan French Balayage',
      likesCount: 148,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PortfolioItem(
      id: 'port-02',
      stylistId: 's1',
      title: 'French Butterfly Feather Cut',
      category: 'Haircut',
      imageUrl: 'assets/images/hair_cut_styling.png',
      description: 'Curtain bangs with internal disconnected layering to maximize natural texture and volume.',
      tags: ['Butterfly Cut', 'Layers', 'Curtain Bangs'],
      serviceName: 'Signature Layer Cut',
      likesCount: 96,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    PortfolioItem(
      id: 'port-03',
      stylistId: 's1',
      title: 'Glossy Mocha Cat Eye Gel Finish',
      category: 'Nails',
      imageUrl: 'assets/images/nail_brown_cat_eye.png',
      description: 'Dual magnet application creating velvet fluid depth on sculpted almond shape.',
      tags: ['Cat Eye', 'Velvet', 'Mocha', 'Almond'],
      serviceName: 'Brown Ombre Cat Eye',
      likesCount: 112,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];
}
