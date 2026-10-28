import '../models/salon_branch.dart';
import 'api_client.dart';

class BranchService {
  static final BranchService _instance = BranchService._internal();
  factory BranchService() => _instance;
  BranchService._internal();

  List<SalonBranch> _cachedBranches = [];
  List<SalonBranch> get cachedBranches => _cachedBranches;

  Future<List<SalonBranch>> getBranches() async {
    try {
      final res = await ApiClient().get('/branches', includeAuth: false);
      if (res is Map<String, dynamic> && res['success'] == true && res['data'] is List) {
        final List list = res['data'];
        final branches = list.map((item) {
          final id = item['branchId']?.toString() ?? item['_id']?.toString() ?? 'branch';
          final name = item['name']?.toString() ?? 'VIORA Salon';
          final address = item['address']?.toString() ?? 'Mumbai';
          final openingTime = item['openingTime']?.toString() ?? '09:00';
          final closingTime = item['closingTime']?.toString() ?? '20:00';

          String imageAsset = 'assets/images/salon_khar.png';
          final lowerName = name.toLowerCase();
          if (lowerName.contains('juhu')) {
            imageAsset = 'assets/images/salon_juhu.png';
          } else if (lowerName.contains('colaba')) {
            imageAsset = 'assets/images/salon_colaba.png';
          }

          final rating = (item['rating'] is num)
              ? (item['rating'] as num).toDouble()
              : (item['avgRating'] is num)
                  ? (item['avgRating'] as num).toDouble()
                  : 4.8;

          final serviceCount = (item['serviceCount'] is num)
              ? (item['serviceCount'] as num).toInt()
              : 42;

          final distanceStr = item['distance']?.toString() ?? '1.2 km';

          final latitude = (item['latitude'] is num)
              ? (item['latitude'] as num).toDouble()
              : null;

          final longitude = (item['longitude'] is num)
              ? (item['longitude'] as num).toDouble()
              : null;

          final servicesList = (item['services'] is List)
              ? (item['services'] as List).map((s) => s.toString()).toList()
              : const [
                  'Hair',
                  'Nails',
                  'Skin',
                  'Makeup',
                  'Beauty',
                  'Consultation',
                  'Balayage',
                  'Facial'
                ];

          return SalonBranch(
            id: id,
            name: name,
            distance: distanceStr,
            rating: rating,
            serviceCount: serviceCount,
            address: address,
            openingHours: 'Open Today: $openingTime - $closingTime',
            imageAsset: imageAsset,
            latitude: latitude,
            longitude: longitude,
            services: servicesList,
          );
        }).toList();

        if (branches.isNotEmpty) {
          _cachedBranches = branches;
          return branches;
        }
      }
    } catch (_) {}

    _cachedBranches = SalonBranch.sampleBranches;
    return SalonBranch.sampleBranches;
  }
}
