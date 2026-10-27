class AdminAnalyticsOverview {
  final int totalBookings;
  final int completedBookings;
  final double totalRevenue;
  final int totalCustomers;
  final int returningCustomers;
  final double retentionRate;

  const AdminAnalyticsOverview({
    this.totalBookings = 0,
    this.completedBookings = 0,
    this.totalRevenue = 0.0,
    this.totalCustomers = 0,
    this.returningCustomers = 0,
    this.retentionRate = 0.0,
  });

  factory AdminAnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AdminAnalyticsOverview(
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? (json['bookings'] as num?)?.toInt() ?? 0,
      completedBookings: (json['completedBookings'] as num?)?.toInt() ?? (json['completed'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? (json['revenue'] as num?)?.toDouble() ?? 0.0,
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? (json['customers'] as num?)?.toInt() ?? 0,
      returningCustomers: (json['returningCustomers'] as num?)?.toInt() ?? (json['returning'] as num?)?.toInt() ?? 0,
      retentionRate: (json['retentionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static const AdminAnalyticsOverview sampleOverview = AdminAnalyticsOverview(
    totalBookings: 148,
    completedBookings: 124,
    totalRevenue: 385500.0,
    totalCustomers: 89,
    returningCustomers: 46,
    retentionRate: 51.7,
  );
}

class BranchPerformance {
  final String branchId;
  final String name;
  final String city;
  final int totalBookings;
  final double revenue;

  const BranchPerformance({
    required this.branchId,
    required this.name,
    required this.city,
    required this.totalBookings,
    required this.revenue,
  });

  factory BranchPerformance.fromJson(Map<String, dynamic> json) {
    return BranchPerformance(
      branchId: json['branchId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? json['branchName'] ?? 'VIORA Atelier',
      city: json['city'] ?? 'Mumbai',
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? (json['bookings'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static const List<BranchPerformance> sampleBranches = [
    BranchPerformance(branchId: 'b1', name: 'Khar West Flagship', city: 'Mumbai', totalBookings: 64, revenue: 168000.0),
    BranchPerformance(branchId: 'b2', name: 'Juhu Tara Luxe', city: 'Mumbai', totalBookings: 51, revenue: 134500.0),
    BranchPerformance(branchId: 'b3', name: 'Bandra Reclamation', city: 'Mumbai', totalBookings: 33, revenue: 83000.0),
  ];
}

class StylistPerformance {
  final String stylistId;
  final String name;
  final double rating;
  final int totalBookings;
  final double revenue;

  const StylistPerformance({
    required this.stylistId,
    required this.name,
    required this.rating,
    required this.totalBookings,
    required this.revenue,
  });

  factory StylistPerformance.fromJson(Map<String, dynamic> json) {
    return StylistPerformance(
      stylistId: json['stylistId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? json['stylistName'] ?? 'Master Stylist',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? (json['bookings'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static const List<StylistPerformance> sampleStylists = [
    StylistPerformance(stylistId: 's1', name: 'Julian Vance', rating: 4.96, totalBookings: 48, revenue: 142000.0),
    StylistPerformance(stylistId: 's2', name: 'Sarah Kothari', rating: 4.92, totalBookings: 42, revenue: 118000.0),
    StylistPerformance(stylistId: 's3', name: 'Jessica Alba', rating: 4.88, totalBookings: 34, revenue: 85500.0),
  ];
}

class PopularService {
  final String serviceId;
  final String name;
  final String category;
  final int bookingsCount;
  final double revenue;

  const PopularService({
    required this.serviceId,
    required this.name,
    required this.category,
    required this.bookingsCount,
    required this.revenue,
  });

  factory PopularService.fromJson(Map<String, dynamic> json) {
    return PopularService(
      serviceId: json['serviceId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? json['serviceName'] ?? 'Salon Service',
      category: json['category'] ?? 'Hair',
      bookingsCount: (json['bookingsCount'] as num?)?.toInt() ?? (json['count'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static const List<PopularService> sampleServices = [
    PopularService(serviceId: 'srv_balayage', name: 'Artisan French Balayage', category: 'Hair', bookingsCount: 38, revenue: 133000.0),
    PopularService(serviceId: 'srv_hydra', name: 'Glass Skin Hydrafacial', category: 'Skin', bookingsCount: 31, revenue: 93000.0),
    PopularService(serviceId: 'srv_cateye', name: 'Brown Ombre Cat Eye', category: 'Nails', bookingsCount: 29, revenue: 43500.0),
  ];
}

class PopularLook {
  final String lookId;
  final String title;
  final String category;
  final int requestsCount;
  final double rating;

  const PopularLook({
    required this.lookId,
    required this.title,
    required this.category,
    required this.requestsCount,
    required this.rating,
  });

  factory PopularLook.fromJson(Map<String, dynamic> json) {
    return PopularLook(
      lookId: json['lookId']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Signature Look',
      category: json['category'] ?? 'Hair',
      requestsCount: (json['requestsCount'] as num?)?.toInt() ?? (json['count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    );
  }

  static const List<PopularLook> sampleLooks = [
    PopularLook(lookId: 'look-balayage-01', title: 'Artisan French Balayage', category: 'Hair', requestsCount: 52, rating: 4.95),
    PopularLook(lookId: 'look-hydra-02', title: 'Glass Skin Hydrafacial Glow', category: 'Skin', requestsCount: 44, rating: 4.98),
    PopularLook(lookId: 'look-cateye-03', title: 'Brown Ombre Velvet Cat Eye', category: 'Nails', requestsCount: 39, rating: 4.90),
  ];
}
