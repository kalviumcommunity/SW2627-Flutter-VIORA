class Stylist {
  final String id;
  final String name;
  final String role; // 'SENIOR STYLIST', 'ART DIRECTOR', 'JUNIOR STYLIST'
  final String location;
  final double overallRating;
  final int reviewCount;
  final int yearsExp;
  final double lookRating;
  final int lookReviewCount;
  final int durationMinutes;
  final int basePrice;
  final String imagePath;
  final bool isAnyAvailable;

  const Stylist({
    required this.id,
    required this.name,
    required this.role,
    required this.location,
    required this.overallRating,
    required this.reviewCount,
    required this.yearsExp,
    required this.lookRating,
    required this.lookReviewCount,
    required this.durationMinutes,
    required this.basePrice,
    required this.imagePath,
    this.isAnyAvailable = false,
  });
    // Allows screens to access the stylist's image using avatarUrl.
    String get avatarUrl => imagePath;

  static const List<Stylist> sampleStylists = [
    Stylist(
      id: 'any',
      name: 'Any Available Stylist',
      role: '',
      location: '',
      overallRating: 5.0,
      reviewCount: 0,
      yearsExp: 0,
      lookRating: 0.0,
      lookReviewCount: 0,
      durationMinutes: 60,
      basePrice: 1800,
      imagePath: '',
      isAnyAvailable: true,
    ),
    Stylist(
      id: 'jessica',
      name: 'Jessica Alba',
      role: 'SENIOR STYLIST',
      location: 'Viora • Model Town',
      overallRating: 4.8,
      reviewCount: 1471,
      yearsExp: 5,
      lookRating: 4.5,
      lookReviewCount: 363,
      durationMinutes: 60,
      basePrice: 1800,
      imagePath: 'assets/images/avatar_jessica.png',
    ),
    Stylist(
      id: 'christian',
      name: 'Christian Dior',
      role: 'ART DIRECTOR',
      location: 'Viora • Khar West',
      overallRating: 4.9,
      reviewCount: 5826,
      yearsExp: 8,
      lookRating: 4.4,
      lookReviewCount: 204,
      durationMinutes: 75,
      basePrice: 2600,
      imagePath: 'assets/images/avatar_christian_dior.png',
    ),
    Stylist(
      id: 'marcus',
      name: 'Marcus Aurelius',
      role: 'SENIOR STYLIST',
      location: 'Viora • Delhi',
      overallRating: 4.5,
      reviewCount: 1095,
      yearsExp: 6,
      lookRating: 3.8,
      lookReviewCount: 56,
      durationMinutes: 80,
      basePrice: 2250,
      imagePath: 'assets/images/avatar_marcus.png',
    ),
    Stylist(
      id: 'sophia',
      name: 'Sophia Loren',
      role: 'JUNIOR STYLIST',
      location: 'Viora • Bangalore',
      overallRating: 4.3,
      reviewCount: 428,
      yearsExp: 3,
      lookRating: 3.7,
      lookReviewCount: 34,
      durationMinutes: 70,
      basePrice: 1700,
      imagePath: 'assets/images/avatar_sophia.png',
    ),
  ];
}
