class SalonBranch {
  final String id;
  final String name;
  final String distance;
  final double rating;
  final int serviceCount;
  final String address;
  final String openingHours;
  final String imageAsset;
  final double? latitude;
  final double? longitude;
  final List<String> services;

  const SalonBranch({
    required this.id,
    required this.name,
    required this.distance,
    required this.rating,
    required this.serviceCount,
    required this.address,
    required this.openingHours,
    required this.imageAsset,
    this.latitude,
    this.longitude,
    this.services = const [
      'Hair',
      'Nails',
      'Skin',
      'Makeup',
      'Beauty',
      'Consultation',
      'Balayage',
      'Facial'
    ],
  });

  static const List<SalonBranch> sampleBranches = [
    SalonBranch(
      id: 'khar-west',
      name: 'VIORA — Khar West',
      distance: '0.8 km',
      rating: 4.8,
      serviceCount: 46,
      address: 'Plot 42, Khar Pali Road, Khar West, Mumbai',
      openingHours: 'Open Today: 10:00 AM - 9:00 PM',
      imageAsset: 'assets/images/salon_khar.png',
      latitude: 19.0700,
      longitude: 72.8350,
      services: ['Hair', 'Nails', 'Skin', 'Makeup', 'Beauty', 'Balayage', 'Facial'],
    ),
    SalonBranch(
      id: 'juhu',
      name: 'VIORA — Juhu',
      distance: '3.2 km',
      rating: 4.7,
      serviceCount: 38,
      address: 'Sea Breeze Building, Juhu Tara Road, Juhu, Mumbai',
      openingHours: 'Open Today: 10:00 AM - 9:00 PM',
      imageAsset: 'assets/images/salon_juhu.png',
      latitude: 19.1075,
      longitude: 72.8263,
      services: ['Hair', 'Nails', 'Skin', 'Makeup', 'Beauty', 'Facial'],
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
      latitude: 18.9220,
      longitude: 72.8347,
      services: ['Hair', 'Nails', 'Skin', 'Makeup', 'Beauty', 'Consultation', 'Balayage'],
    ),
  ];
}
