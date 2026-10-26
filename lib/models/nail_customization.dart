class DesignCategory {
  final String name;
  final List<String> options;

  const DesignCategory({
    required this.name,
    required this.options,
  });

  static const List<DesignCategory> allCategories = [
    DesignCategory(
      name: 'Ombre & Gradients',
      options: [
        'Classic Vertical Ombre',
        'Inverted Ombre',
        'Horizontal Ombre',
        'Aura Ombre',
        'French Ombre',
        'Skittle Ombre',
      ],
    ),
    DesignCategory(
      name: 'French Tips & Fades',
      options: [
        'Classic French Tip',
        'Micro French Tip',
        'Double French Tip',
        'V-Cut French Tip',
        'Deep French Tip',
        'Slanted French Tip',
        'Glitter Fade Tip',
        'Cat-Eye Fade Tip',
      ],
    ),
    DesignCategory(
      name: 'Texture & Illusion Art',
      options: [
        'Marble Art',
        'Tortoiseshell Art',
        'Classic Croc Print',
        'Velvet Wave',
        'Blooming Gel Florals',
        'Shattered Glass',
        'Crackle Effect',
      ],
    ),
    DesignCategory(
      name: 'Flat Paint & Line Art',
      options: [
        'Abstract Swirls',
        'Geometric & Grid Art',
        'Minimalist Dots',
        'Fine-Line Florals',
        'Celestial Motif Art',
        'Animal Print',
        'Pop Art',
        'Custom Typography',
        'Portrait Painting',
      ],
    ),
    DesignCategory(
      name: '3D & Sculpted Art',
      options: [
        'Liquid Metal',
        'Sweater Knit Texture',
        'Dewdrops',
        'Mermaid Shell Sculpt',
        'Pillow Quilt',
        'Molded Charms',
        'Classic Croc Print 3D',
      ],
    ),
    DesignCategory(
      name: 'Embellishments & Charms',
      options: [
        'Rhinestone Clusters',
        'Statement Charms',
        'Encapsulated Art',
        'Pixie Dust',
        'Nail Piercings',
      ],
    ),
  ];
}
