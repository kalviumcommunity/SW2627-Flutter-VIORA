import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedSectionIndex = 0; // 0: Branches, 1: Services, 2: Categories, 3: Availability, 4: Stylist Assignment

  final List<String> _sectionTitles = [
    '1. Branch Management',
    '2. Service Management',
    '3. Service Categories',
    '4. Branch-wise Availability',
    '5. Stylist Assignment',
  ];

  // 1. Branch Data
  List<Map<String, dynamic>> _branches = [
    {
      'id': 'b1',
      'name': 'Model Town',
      'city': 'Jalandhar',
      'isOpen': true,
      'image': 'assets/images/salon_khar.png',
    },
    {
      'id': 'b2',
      'name': 'Phagwara',
      'city': 'Phagwara',
      'isOpen': true,
      'image': 'assets/images/salon_juhu.png',
    },
    {
      'id': 'b3',
      'name': 'Jalandhar',
      'city': 'Jalandhar',
      'isOpen': true,
      'image': 'assets/images/salon_colaba.png',
    },
    {
      'id': 'b4',
      'name': 'Ludhiana',
      'city': 'Ludhiana',
      'isOpen': true,
      'image': 'assets/images/salon_hero.png',
    },
  ];

  // 2. Services Data
  List<Map<String, dynamic>> _services = [
    {
      'id': 's1',
      'name': 'Hair Cut',
      'category': 'Hair',
      'price': 800,
      'image': 'assets/images/hair_cut_styling.png',
    },
    {
      'id': 's2',
      'name': 'Gel Polish',
      'category': 'Nails',
      'price': 1200,
      'image': 'assets/images/service_nails.png',
    },
    {
      'id': 's3',
      'name': 'Facial',
      'category': 'Skin',
      'price': 2000,
      'image': 'assets/images/skin_facials.png',
    },
    {
      'id': 's4',
      'name': 'Threading',
      'category': 'Eyes & Brows',
      'price': 300,
      'image': 'assets/images/removal_threading.png',
    },
  ];

  // 3. Categories Data
  List<Map<String, dynamic>> _categories = [
    {
      'id': 'c1',
      'name': 'Hair',
      'isActive': true,
      'image': 'assets/images/service_hair.png',
    },
    {
      'id': 'c2',
      'name': 'Skin',
      'isActive': true,
      'image': 'assets/images/service_skin.png',
    },
    {
      'id': 'c3',
      'name': 'Nails',
      'isActive': true,
      'image': 'assets/images/service_nails.png',
    },
    {
      'id': 'c4',
      'name': 'Threading',
      'isActive': true,
      'image': 'assets/images/removal_threading.png',
    },
    {
      'id': 'c5',
      'name': 'Waxing',
      'isActive': true,
      'image': 'assets/images/removal_waxing.png',
    },
  ];

  // 4. Availability Data
  String _availabilityBranch = 'Model Town';
  String _availabilityService = 'Gel Polish';
  List<Map<String, dynamic>> _availabilityStylists = [
    {
      'id': 'st1',
      'name': 'Jessica Alba',
      'tag': 'Premium',
      'isAvailable': true,
      'avatar': 'assets/images/avatar_jessica.png',
    },
    {
      'id': 'st2',
      'name': 'Maya',
      'tag': 'Top Rated',
      'isAvailable': true,
      'avatar': 'assets/images/avatar_sophia.png',
    },
    {
      'id': 'st3',
      'name': 'Ananya',
      'tag': 'Specialist',
      'isAvailable': false,
      'avatar': 'assets/images/avatar_sarah.png',
    },
  ];

  // 5. Stylist Assignment Data
  String _assignmentBranch = 'Model Town';
  List<Map<String, dynamic>> _assignedStylists = [
    {
      'id': 'as1',
      'name': 'Jessica Alba',
      'specialty': 'Nail Artist',
      'isAssigned': true,
      'avatar': 'assets/images/avatar_jessica.png',
    },
    {
      'id': 'as2',
      'name': 'Maya',
      'specialty': 'Hair Specialist',
      'isAssigned': true,
      'avatar': 'assets/images/avatar_sophia.png',
    },
    {
      'id': 'as3',
      'name': 'Ananya',
      'specialty': 'Skin Specialist',
      'isAssigned': true,
      'avatar': 'assets/images/avatar_sarah.png',
    },
    {
      'id': 'as4',
      'name': 'Riya',
      'specialty': 'Nail Artist',
      'isAssigned': false,
      'avatar': 'assets/images/avatar_marcus.png',
    },
  ];

  // Primary palette matching reference image
  static const Color adminDarkSidebar = Color(0xFF2C2B2A);
  static const Color adminActiveBlush = Color(0xFFF3E5E2);
  static const Color adminActiveBlushText = Color(0xFF2C2B2A);
  static const Color adminButtonDustyRose = Color(0xFF8D5A54);
  static const Color adminSageHeaderBg = Color(0xFFDFE9E0);
  static const Color adminSageHeaderBorder = Color(0xFFCFDCD0);
  static const Color adminCardBg = Colors.white;
  static const Color adminPageBg = Color(0xFFF5F7F5);

  void _showAddBranchDialog() {
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Branch',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Branch Name (e.g. Model Town)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(
                labelText: 'City (e.g. Jalandhar)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: adminButtonDustyRose,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _branches.add({
                    'id': 'b_${DateTime.now().millisecondsSinceEpoch}',
                    'name': nameCtrl.text.trim(),
                    'city': cityCtrl.text.trim().isEmpty
                        ? 'Punjab'
                        : cityCtrl.text.trim(),
                    'isOpen': true,
                    'image': 'assets/images/salon_khar.png',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: adminButtonDustyRose,
                    content: Text('Branch "${nameCtrl.text.trim()}" added.'),
                  ),
                );
              }
            },
            child: const Text('Add Branch'),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog() {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Hair');
    final priceCtrl = TextEditingController(text: '1000');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Service',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Service Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (₹)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: adminButtonDustyRose,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _services.add({
                    'id': 's_${DateTime.now().millisecondsSinceEpoch}',
                    'name': nameCtrl.text.trim(),
                    'category': categoryCtrl.text.trim(),
                    'price': int.tryParse(priceCtrl.text) ?? 800,
                    'image': 'assets/images/service_hair.png',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: adminButtonDustyRose,
                    content: Text('Service "${nameCtrl.text.trim()}" added.'),
                  ),
                );
              }
            },
            child: const Text('Add Service'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final catCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Category',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: TextField(
          controller: catCtrl,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: adminButtonDustyRose,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (catCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _categories.add({
                    'id': 'c_${DateTime.now().millisecondsSinceEpoch}',
                    'name': catCtrl.text.trim(),
                    'isActive': true,
                    'image': 'assets/images/service_hair.png',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: adminButtonDustyRose,
                    content: Text('Category "${catCtrl.text.trim()}" added.'),
                  ),
                );
              }
            },
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: adminPageBg,
      // Drawer on Mobile
      drawer: isDesktop ? null : _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Top Green Aesthetic Accent Bar (matching reference header)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: adminSageHeaderBg,
                border: Border(
                  bottom: BorderSide(color: adminSageHeaderBorder, width: 1.2),
                ),
              ),
              child: Row(
                children: [
                  if (!isDesktop)
                    Builder(
                      builder: (innerContext) => GestureDetector(
                        onTap: () => Scaffold.of(innerContext).openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: adminSageHeaderBorder),
                          ),
                          child: const Icon(Icons.menu,
                              size: 20, color: adminDarkSidebar),
                        ),
                      ),
                    ),
                  if (!isDesktop) const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: adminSageHeaderBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 16, color: adminDarkSidebar),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // MAISON Brand Pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: adminDarkSidebar,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'MAISON',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ADMIN DASHBOARD',
                      style: AppTextStyles.editorialTitle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ).copyWith(color: const Color(0xFF2C3E2C)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Return to Customer App Badge
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushReplacementNamed('/home'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: adminSageHeaderBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.storefront,
                              size: 14, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Client App',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area (Sidebar on Desktop, Tabs on Mobile)
            Expanded(
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Desktop Sidebar
                        Container(
                          width: 220,
                          color: adminDarkSidebar,
                          child: _buildSidebarContent(),
                        ),
                        // Right Desktop Content Area
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            child: _buildActiveSectionCard(),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Mobile Section Selector Tabs (Scrollable)
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(_sectionTitles.length,
                                  (index) {
                                final isSelected =
                                    _selectedSectionIndex == index;
                                final shortTitle = _sectionTitles[index]
                                    .replaceAll(RegExp(r'^\d+\.\s*'), '');

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedSectionIndex = index),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? adminButtonDustyRose
                                            : const Color(0xFFF0EFEB),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? adminButtonDustyRose
                                              : const Color(0xFFE2DFD8),
                                        ),
                                      ),
                                      child: Text(
                                        shortTitle,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF4A4642),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE2E7E2)),

                        // Mobile Operational Content Area
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: _buildActiveSectionCard(),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar Drawer for Mobile
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: adminDarkSidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: const [
                  Text(
                    'MAISON',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF3E3C3A)),
            Expanded(child: _buildSidebarContent()),
          ],
        ),
      ),
    );
  }

  // Sidebar Content with Menu Items
  Widget _buildSidebarContent() {
    final menuItems = [
      {'title': 'Dashboard', 'icon': Icons.home_outlined, 'section': -1},
      {
        'title': 'Branches',
        'icon': Icons.location_on_outlined,
        'section': 0
      },
      {'title': 'Services', 'icon': Icons.content_cut_outlined, 'section': 1},
      {'title': 'Categories', 'icon': Icons.grid_view_outlined, 'section': 2},
      {
        'title': 'Availability',
        'icon': Icons.event_available_outlined,
        'section': 3
      },
      {'title': 'Stylists', 'icon': Icons.people_outline, 'section': 4},
      {'title': 'Settings', 'icon': Icons.settings_outlined, 'section': -1},
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: menuItems.map((item) {
        final section = item['section'] as int;
        final isSelected =
            section >= 0 && _selectedSectionIndex == section;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: ListTile(
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: isSelected ? adminActiveBlush : Colors.transparent,
            leading: Icon(
              item['icon'] as IconData,
              size: 20,
              color: isSelected
                  ? adminActiveBlushText
                  : const Color(0xFFA8A39D),
            ),
            title: Text(
              item['title'] as String,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? adminActiveBlushText
                    : const Color(0xFFA8A39D),
              ),
            ),
            onTap: () {
              if (section >= 0) {
                setState(() => _selectedSectionIndex = section);
                if (Navigator.of(context).canPop() &&
                    Scaffold.of(context).isDrawerOpen) {
                  Navigator.of(context).pop();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: adminButtonDustyRose,
                    content: Text('${item['title']} section selected.'),
                    duration: const Duration(milliseconds: 1200),
                  ),
                );
              }
            },
          ),
        );
      }).toList(),
    );
  }

  // Active Section Router
  Widget _buildActiveSectionCard() {
    switch (_selectedSectionIndex) {
      case 0:
        return _buildBranchManagementSection();
      case 1:
        return _buildServiceManagementSection();
      case 2:
        return _buildServiceCategoriesSection();
      case 3:
        return _buildBranchWiseAvailabilitySection();
      case 4:
        return _buildStylistAssignmentSection();
      default:
        return _buildBranchManagementSection();
    }
  }

  // Section 1: Branch Management
  Widget _buildBranchManagementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: adminCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E7E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: "Branches" & "+ Add Branch"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Branches',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2928),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddBranchDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Branch',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: adminButtonDustyRose,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFFEBEBEB), height: 1),
          const SizedBox(height: 14),

          // Branch Cards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _branches.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Color(0xFFF0EFEB), height: 20),
            itemBuilder: (context, index) {
              final branch = _branches[index];
              final isOpen = branch['isOpen'] as bool;

              return Row(
                children: [
                  // Branch Thumbnail
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFF0EFEB),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      branch['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.storefront,
                              color: adminButtonDustyRose),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & City
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch['name'] as String,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B2928),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          branch['city'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A7672),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Open / Closed Status Badge (Matching Reference Image)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? const Color(0xFFE6F4EA)
                          : const Color(0xFFFBE9E7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isOpen
                            ? const Color(0xFF1E7E34)
                            : const Color(0xFFD32F2F),
                      ),
                    ),
                  ),

                  // 3-dots Menu Popup
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 20, color: Color(0xFF7A7672)),
                    onSelected: (action) {
                      if (action == 'toggle') {
                        setState(() {
                          branch['isOpen'] = !isOpen;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: adminButtonDustyRose,
                            content: Text(
                                '${branch['name']} is now ${!isOpen ? "Open" : "Closed"}.'),
                          ),
                        );
                      } else if (action == 'delete') {
                        setState(() {
                          _branches.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: adminButtonDustyRose,
                            content: Text('${branch['name']} removed.'),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(isOpen ? 'Mark Closed' : 'Mark Open'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Branch',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Section 2: Service Management
  Widget _buildServiceManagementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: adminCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E7E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: "Services" & "+ Add Service"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2928),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddServiceDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Service',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: adminButtonDustyRose,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFFEBEBEB), height: 1),
          const SizedBox(height: 14),

          // Services List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Color(0xFFF0EFEB), height: 20),
            itemBuilder: (context, index) {
              final s = _services[index];

              return Row(
                children: [
                  // Service Image Thumbnail
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFF0EFEB),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      s['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.spa, color: adminButtonDustyRose),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['name'] as String,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B2928),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s['category'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A7672),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price (e.g. ₹800, ₹1,200)
                  Text(
                    '₹${s['price']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2B2928),
                    ),
                  ),

                  // 3-dots Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 20, color: Color(0xFF7A7672)),
                    onSelected: (action) {
                      if (action == 'delete') {
                        setState(() {
                          _services.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: adminButtonDustyRose,
                            content: Text('${s['name']} removed.'),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Price'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Service',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Section 3: Service Categories
  Widget _buildServiceCategoriesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: adminCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E7E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: "Categories" & "+ Add Category"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2928),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Category',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: adminButtonDustyRose,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFFEBEBEB), height: 1),
          const SizedBox(height: 14),

          // Categories with Circular Images and Toggle Switches
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Color(0xFFF0EFEB), height: 16),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isActive = cat['isActive'] as bool;

              return Row(
                children: [
                  // Circular Thumbnail
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF0EFEB),
                    backgroundImage: AssetImage(cat['image'] as String),
                    onBackgroundImageError: (exception, stackTrace) {},
                  ),
                  const SizedBox(width: 16),

                  // Category Name
                  Expanded(
                    child: Text(
                      cat['name'] as String,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2B2928),
                      ),
                    ),
                  ),

                  // Toggle Switch (Soft green active state matching reference)
                  Switch.adaptive(
                    value: isActive,
                    activeColor: const Color(0xFF4CAF50),
                    activeTrackColor: const Color(0xFFC8E6C9),
                    onChanged: (val) {
                      setState(() {
                        cat['isActive'] = val;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: adminButtonDustyRose,
                          content: Text(
                              'Category "${cat['name']}" is now ${val ? "Active" : "Inactive"}.'),
                          duration: const Duration(milliseconds: 1000),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Section 4: Branch-wise Availability
  Widget _buildBranchWiseAvailabilitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: adminCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E7E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Availability',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2928),
            ),
          ),

          const SizedBox(height: 16),

          // Dropdowns Row (Select Branch & Select Service)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 400;

              final branchDropdown = Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD4D0C8)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _availabilityBranch,
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B2928),
                    ),
                    items: ['Model Town', 'Phagwara', 'Jalandhar', 'Ludhiana']
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _availabilityBranch = val);
                    },
                  ),
                ),
              );

              final serviceDropdown = Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD4D0C8)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _availabilityService,
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B2928),
                    ),
                    items: ['Gel Polish', 'Hair Cut', 'Facial', 'Threading']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _availabilityService = val);
                    },
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    branchDropdown,
                    const SizedBox(height: 10),
                    serviceDropdown,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: branchDropdown),
                  const SizedBox(width: 12),
                  Expanded(child: serviceDropdown),
                ],
              );
            },
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFEBEBEB), height: 1),
          const SizedBox(height: 14),

          // Stylists with Avatars, Role Tags, and Toggle Switches
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availabilityStylists.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Color(0xFFF0EFEB), height: 16),
            itemBuilder: (context, index) {
              final st = _availabilityStylists[index];
              final isAvail = st['isAvailable'] as bool;

              return Row(
                children: [
                  // Circular Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF0EFEB),
                    backgroundImage: AssetImage(st['avatar'] as String),
                    onBackgroundImageError: (exception, stackTrace) {},
                  ),
                  const SizedBox(width: 14),

                  // Name & Role Tag
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          st['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B2928),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          st['tag'] as String,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF8A8580),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Toggle Switch
                  Switch.adaptive(
                    value: isAvail,
                    activeColor: const Color(0xFF4CAF50),
                    activeTrackColor: const Color(0xFFC8E6C9),
                    onChanged: (val) {
                      setState(() {
                        st['isAvailable'] = val;
                      });
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Save Button (Right-aligned, dusty rose)
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: adminButtonDustyRose,
                    content: Text(
                        'Availability saved for $_availabilityBranch • $_availabilityService.'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: adminButtonDustyRose,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section 5: Stylist Assignment
  Widget _buildStylistAssignmentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: adminCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E7E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assign Stylists to Branch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2928),
            ),
          ),

          const SizedBox(height: 16),

          // Branch Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4D0C8)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _assignmentBranch,
                isExpanded: true,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B2928),
                ),
                items: ['Model Town', 'Phagwara', 'Jalandhar', 'Ludhiana']
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _assignmentBranch = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFEBEBEB), height: 1),
          const SizedBox(height: 14),

          // Stylists with Checkbox, Avatar, Name, Specialty
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _assignedStylists.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Color(0xFFF0EFEB), height: 16),
            itemBuilder: (context, index) {
              final as = _assignedStylists[index];
              final isAssigned = as['isAssigned'] as bool;

              return InkWell(
                onTap: () {
                  setState(() {
                    as['isAssigned'] = !isAssigned;
                  });
                },
                child: Row(
                  children: [
                    // Checkbox
                    Checkbox(
                      value: isAssigned,
                      activeColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) {
                        setState(() {
                          as['isAssigned'] = val ?? false;
                        });
                      },
                    ),
                    const SizedBox(width: 4),

                    // Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFF0EFEB),
                      backgroundImage: AssetImage(as['avatar'] as String),
                      onBackgroundImageError: (exception, stackTrace) {},
                    ),
                    const SizedBox(width: 14),

                    // Name & Specialty
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            as['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2B2928),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            as['specialty'] as String,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF8A8580),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Save Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                final assignedCount = _assignedStylists
                    .where((s) => s['isAssigned'] == true)
                    .length;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: adminButtonDustyRose,
                    content: Text(
                        '$assignedCount stylists assigned to $_assignmentBranch.'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: adminButtonDustyRose,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
