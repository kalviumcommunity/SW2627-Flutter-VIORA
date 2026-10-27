class NailService {
  final String id;
  final String title;
  final String stylist;
  final String stylistRole;
  final double rating;
  final int reviewsCount;
  final String price;
  final String duration;
  final String imageAsset;
  final String section; // 'TRENDING', 'TOP RATED', 'EXPLORE THE COLLECTION'
  final List<String> colors;

  const NailService({
    required this.id,
    required this.title,
    required this.stylist,
    required this.stylistRole,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    required this.duration,
    required this.imageAsset,
    required this.section,
    required this.colors,
  });

  static const List<NailService> allNailServices = [
    // 1. TRENDING
    NailService(
      id: 'brown-ombre-cat-eye',
      title: 'Brown Ombre Cat Eye',
      stylist: 'Jessica Alba',
      stylistRole: 'Senior Stylist',
      rating: 4.0,
      reviewsCount: 888,
      price: '₹1,800',
      duration: '60 min',
      imageAsset: 'assets/images/nail_brown_cat_eye.png',
      section: 'TRENDING',
      colors: ['Brown', 'Amber'],
    ),
    NailService(
      id: 'mocha-latte-flower',
      title: 'Mocha Latte Flower',
      stylist: 'Jenny Bui',
      stylistRole: 'Creative Director',
      rating: 3.9,
      reviewsCount: 400,
      price: '₹2,980',
      duration: '90 min',
      imageAsset: 'assets/images/nail_mocha_flower.png',
      section: 'TRENDING',
      colors: ['Brown', 'Beige'],
    ),

    // 2. TOP RATED
    NailService(
      id: 'classic-matte-mocha',
      title: 'Classic Matte Mocha',
      stylist: 'Coca Michelle',
      stylistRole: 'Style Director',
      rating: 4.9,
      reviewsCount: 136,
      price: '₹4,000',
      duration: '60 min',
      imageAsset: 'assets/images/nail_matte_mocha.png',
      section: 'TOP RATED',
      colors: ['Brown'],
    ),
    NailService(
      id: 'leopard-tortie-gold-tips',
      title: 'Leopard Tortie Gold Tips',
      stylist: 'Jenny Bui',
      stylistRole: 'Style Director',
      rating: 4.8,
      reviewsCount: 183,
      price: '₹4,800',
      duration: '180 min',
      imageAsset: 'assets/images/nail_leopard_tortie.png',
      section: 'TOP RATED',
      colors: ['Brown', 'Gold', 'Amber'],
    ),

    // 3. EXPLORE THE COLLECTION
    NailService(
      id: 'brown-metallic-skittle',
      title: 'Brown Metallic Skittle',
      stylist: 'Betina R. Goldstein',
      stylistRole: 'Top Stylist',
      rating: 4.1,
      reviewsCount: 127,
      price: '₹2,300',
      duration: '90 min',
      imageAsset: 'assets/images/nail_metallic_skittle.png',
      section: 'EXPLORE THE COLLECTION',
      colors: ['Brown', 'Gold'],
    ),
    NailService(
      id: 'brown-polka-cat-eye',
      title: 'Brown Polka Cat Eye',
      stylist: 'Cam Tran',
      stylistRole: 'Stylist',
      rating: 3.9,
      reviewsCount: 78,
      price: '₹2,000',
      duration: '90 min',
      imageAsset: 'assets/images/nail_polka_cat_eye.png',
      section: 'EXPLORE THE COLLECTION',
      colors: ['Brown', 'Beige'],
    ),
  ];
   // Alias required by FirestoreService.
    static const List<NailService> sampleNailServices = allNailServices;
}
