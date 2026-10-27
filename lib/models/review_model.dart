class ReviewItem {
  final String id;
  final String appointmentId;
  final String customerId;
  final String userName;
  final String? userAvatar;
  final String stylistId;
  final String stylistName;
  final String serviceName;
  final int overallRating;
  final int lookRating;
  final int stylistRating;
  final String comments;
  final List<String> photos;
  final String status;
  final DateTime createdAt;

  const ReviewItem({
    required this.id,
    required this.appointmentId,
    required this.customerId,
    required this.userName,
    this.userAvatar,
    required this.stylistId,
    required this.stylistName,
    required this.serviceName,
    required this.overallRating,
    this.lookRating = 5,
    this.stylistRating = 5,
    required this.comments,
    this.photos = const [],
    this.status = 'published',
    required this.createdAt,
  });

  int get rating => overallRating;
  String get customerName => userName;

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      appointmentId: json['appointmentId']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      userName: json['userName'] ?? json['customerName'] ?? 'Anonymous Client',
      userAvatar: json['userAvatar'],
      stylistId: json['stylistId']?.toString() ?? '',
      stylistName: json['stylistName'] ?? 'Master Stylist',
      serviceName: json['serviceName'] ?? json['serviceTitle'] ?? 'Atelier Treatment',
      overallRating: (json['overallRating'] as num?)?.toInt() ?? (json['rating'] as num?)?.toInt() ?? 5,
      lookRating: (json['lookRating'] as num?)?.toInt() ?? 5,
      stylistRating: (json['stylistRating'] as num?)?.toInt() ?? 5,
      comments: json['comments'] ?? json['comment'] ?? '',
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] ?? 'published',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'customerId': customerId,
      'userName': userName,
      'userAvatar': userAvatar,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'serviceName': serviceName,
      'overallRating': overallRating,
      'lookRating': lookRating,
      'stylistRating': stylistRating,
      'comments': comments,
      'photos': photos,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static final List<ReviewItem> sampleReviews = [
    ReviewItem(
      id: 'rev-01',
      appointmentId: 'apt-101',
      customerId: 'c-01',
      userName: 'Aanya Sharma',
      userAvatar: 'assets/images/avatar_sarah.png',
      stylistId: 's1',
      stylistName: 'Julian Vance',
      serviceName: 'Artisan French Balayage',
      overallRating: 5,
      lookRating: 5,
      stylistRating: 5,
      comments: 'Julian is an absolute visionary. The dimension in my balayage is subtle yet completely transforms my face shape in natural sunlight.',
      photos: ['assets/images/hair_colour.png'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ReviewItem(
      id: 'rev-02',
      appointmentId: 'apt-102',
      customerId: 'c-02',
      userName: 'Tara Singhania',
      userAvatar: 'assets/images/avatar_sarah.png',
      stylistId: 's1',
      stylistName: 'Julian Vance',
      serviceName: 'Signature Layer Cut',
      overallRating: 5,
      lookRating: 5,
      stylistRating: 5,
      comments: 'The Khar West atelier is breathtaking. Julian took the time to understand my hair texture before lifting a single pair of scissors.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ReviewItem(
      id: 'rev-03',
      appointmentId: 'apt-103',
      customerId: 'c-03',
      userName: 'Rhea Kapoor',
      userAvatar: 'assets/images/avatar_sarah.png',
      stylistId: 's1',
      stylistName: 'Julian Vance',
      serviceName: 'Gloss Hair Spa',
      overallRating: 4,
      lookRating: 5,
      stylistRating: 4,
      comments: 'Silky smooth finish and immaculate attention to scalp health. Definitely booking my next ritual here.',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
  ];
}

class StylistReviewStats {
  final double averageOverall;
  final double averageLook;
  final double averageStylist;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  const StylistReviewStats({
    this.averageOverall = 5.0,
    this.averageLook = 5.0,
    this.averageStylist = 5.0,
    this.totalReviews = 0,
    this.ratingDistribution = const {5: 10, 4: 2, 3: 0, 2: 0, 1: 0},
  });

  double get averageRating => averageOverall;
  double get averageLookRating => averageLook;

  factory StylistReviewStats.fromJson(Map<String, dynamic> json) {
    final distRaw = json['ratingDistribution'] as Map<String, dynamic>? ?? {};
    final dist = <int, int>{};
    distRaw.forEach((k, v) {
      final star = int.tryParse(k) ?? 5;
      dist[star] = (v as num).toInt();
    });

    return StylistReviewStats(
      averageOverall: (json['averageOverall'] as num?)?.toDouble() ?? (json['averageRating'] as num?)?.toDouble() ?? 5.0,
      averageLook: (json['averageLook'] as num?)?.toDouble() ?? (json['averageLookRating'] as num?)?.toDouble() ?? 5.0,
      averageStylist: (json['averageStylist'] as num?)?.toDouble() ?? 5.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      ratingDistribution: dist.isNotEmpty ? dist : {5: 42, 4: 8, 3: 1, 2: 0, 1: 0},
    );
  }

  static const StylistReviewStats sampleStats = StylistReviewStats(
    averageOverall: 4.92,
    averageLook: 4.95,
    averageStylist: 4.90,
    totalReviews: 51,
    ratingDistribution: {5: 45, 4: 5, 3: 1, 2: 0, 1: 0},
  );
}

class EligibleAppointment {
  final String id;
  final String serviceTitle;
  final String stylistId;
  final String stylistName;
  final String stylistRole;
  final String branchName;
  final DateTime appointmentDate;

  const EligibleAppointment({
    required this.id,
    required this.serviceTitle,
    required this.stylistId,
    required this.stylistName,
    this.stylistRole = 'Master Stylist',
    required this.branchName,
    required this.appointmentDate,
  });

  String get appointmentId => id;
  String get serviceName => serviceTitle;
  DateTime get date => appointmentDate;

  factory EligibleAppointment.fromJson(Map<String, dynamic> json) {
    return EligibleAppointment(
      id: json['id']?.toString() ?? json['appointmentId']?.toString() ?? json['_id']?.toString() ?? '',
      serviceTitle: json['serviceTitle'] ?? json['serviceName'] ?? 'Atelier Treatment',
      stylistId: json['stylistId']?.toString() ?? '',
      stylistName: json['stylistName'] ?? 'Master Stylist',
      stylistRole: json['stylistRole'] ?? 'Specialist',
      branchName: json['branchName'] ?? json['salonBranch'] ?? 'VIORA Khar West',
      appointmentDate: json['appointmentDate'] != null
          ? DateTime.parse(json['appointmentDate'].toString())
          : (json['date'] != null ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  static final List<EligibleAppointment> sampleEligible = [
    EligibleAppointment(
      id: 'VIO-89421',
      serviceTitle: 'Artisan French Balayage',
      stylistId: 's1',
      stylistName: 'Julian Vance',
      stylistRole: 'Art Director & Master Colorist',
      branchName: 'VIORA — Khar West Flagship',
      appointmentDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
    EligibleAppointment(
      id: 'VIO-78102',
      serviceTitle: 'Brown Ombre Velvet Cat Eye',
      stylistId: 's3',
      stylistName: 'Jessica Alba',
      stylistRole: 'Lead Nail Artist',
      branchName: 'VIORA — Juhu Flagship',
      appointmentDate: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];
}
