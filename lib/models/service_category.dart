class ServiceCategory {
  final String id;
  final String name;
  final String imageAsset;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.imageAsset,
  });

  static const List<ServiceCategory> allCategories = [
    ServiceCategory(
      id: 'hair',
      name: 'Hair',
      imageAsset: 'assets/images/service_hair.png',
    ),
    ServiceCategory(
      id: 'skin',
      name: 'Skin',
      imageAsset: 'assets/images/service_skin.png',
    ),
    ServiceCategory(
      id: 'nails',
      name: 'Nails',
      imageAsset: 'assets/images/service_nails.png',
    ),
    ServiceCategory(
      id: 'hair_removal',
      name: 'Hair Removal',
      imageAsset: 'assets/images/service_removal.png',
    ),
    ServiceCategory(
      id: 'eyes_brows',
      name: 'Eyes & Brows',
      imageAsset: 'assets/images/service_brows.png',
    ),
    ServiceCategory(
      id: 'massage',
      name: 'Massage',
      imageAsset: 'assets/images/service_massage.png',
    ),
    ServiceCategory(
      id: 'makeup',
      name: 'Makeup',
      imageAsset: 'assets/images/service_makeup.png',
    ),
    ServiceCategory(
      id: 'mens_grooming',
      name: "Men's Grooming",
      imageAsset: 'assets/images/service_grooming.png',
    ),
  ];
}
