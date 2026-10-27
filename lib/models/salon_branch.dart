class SalonBranch {
  final String id;
  final String name;
  final String distance;
  final double rating;
  final int serviceCount;
  final String address;
  final String openingHours;
  final String imageAsset;

  const SalonBranch({
    required this.id,
    required this.name,
    required this.distance,
    required this.rating,
    required this.serviceCount,
    required this.address,
    required this.openingHours,
    required this.imageAsset,
  });

  static const List<SalonBranch> sampleBranches = [
    SalonBranch(
      id: 'khar-west',
      name: 'VIORA — Khar West',
      distance: '0.8 km',
      rating: 4.9,
      serviceCount: 48,
      address: 'Plot 42, Khar Pali Road, Khar West, Mumbai',
      openingHours: 'Open Today: 10:00 AM - 9:00 PM',
      imageAsset: 'assets/images/salon_khar.png',
    ),
    SalonBranch(
      id: 'juhu',
      name: 'VIORA — Juhu',
      distance: '3.2 km',
      rating: 4.8,
      serviceCount: 45,
      address: 'Sea Breeze Building, Juhu Tara Road, Juhu, Mumbai',
      openingHours: 'Open Today: 10:00 AM - 9:00 PM',
      imageAsset: 'assets/images/salon_juhu.png',
    ),
    SalonBranch(
      id: 'colaba',
      name: 'VIORA — Colaba',
      distance: '18.4 km',
      rating: 4.9,
      serviceCount: 52,
      address: 'Taj Mahal Palace, Apollo Bandar, Colaba, Mumbai',
      openingHours: 'Open Today: 9:00 AM - 8:00 PM',
      imageAsset: 'assets/images/salon_colaba.png',
    ),
  ];
}
