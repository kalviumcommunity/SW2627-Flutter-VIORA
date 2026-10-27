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

          return SalonBranch(
            id: id,
            name: name,
            distance: '1.2 km',
            rating: 4.9,
            serviceCount: 48,
            address: address,
            openingHours: 'Open Today: $openingTime - $closingTime',
            imageAsset: imageAsset,
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
