import 'package:flutter_test/flutter_test.dart';
import 'package:viora_salon_app/services/inspiration_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Person 3 — Inspiration Flow & Discovery Unit Tests', () {
    final service = InspirationService();

    test('1. Discovery feed returns curated sample looks with tags and rating', () async {
      final looks = await service.getDiscoveryFeed();
      expect(looks.isNotEmpty, isTrue);
      expect(looks.any((l) => l.category == 'Hair'), isTrue);
      expect(looks.any((l) => l.tags.contains('Balayage')), isTrue);
      expect(looks.first.rating, greaterThanOrEqualTo(4.5));
    });

    test('2. Discovery feed filters by category accurately', () async {
      final hairLooks = await service.getDiscoveryFeed(category: 'Hair');
      expect(hairLooks.every((l) => l.category.toLowerCase() == 'hair'), isTrue);

      final skinLooks = await service.getDiscoveryFeed(category: 'Skin');
      expect(skinLooks.every((l) => l.category.toLowerCase() == 'skin'), isTrue);
    });

    test('3. Discovery feed filters by search query on title and tags', () async {
      final balayageResults = await service.getDiscoveryFeed(search: 'balayage');
      expect(balayageResults.isNotEmpty, isTrue);
      expect(balayageResults.first.title.toLowerCase().contains('balayage') ||
             balayageResults.first.tags.any((t) => t.toLowerCase().contains('balayage')), isTrue);
    });

    test('4. Look bookmark toggle toggles and persists in memory', () {
      const lookId = 'look-balayage-01';
      expect(service.isBookmarked(lookId), isFalse);

      service.toggleBookmark(lookId);
      expect(service.isBookmarked(lookId), isTrue);

      service.toggleBookmark(lookId);
      expect(service.isBookmarked(lookId), isFalse);
    });

    test('5. Creating custom inspiration request returns request with stylist proposals', () async {
      final request = await service.createRequest(
        imageUrl: 'assets/images/hair_colour.png',
        description: 'Bespoke Parisian blonde balayage with face framing highlights',
        category: 'Hair',
        preferredBranchId: 'khar-west',
        budgetRange: '₹6,000 - ₹9,000',
        notes: 'Fine texture, low porosity',
      );

      expect(request.id.isNotEmpty, isTrue);
      expect(request.category, equals('Hair'));
      expect(request.responses.length, greaterThanOrEqualTo(2));
      expect(request.responses.first.stylistName.isNotEmpty, isTrue);
      expect(request.responses.first.estimatedCost, greaterThan(0));
    });

    test('6. Choosing stylist accepts response and generates booking handoff context', () async {
      final request = await service.createRequest(
        imageUrl: 'assets/images/service_facial.png',
        description: 'Glass skin hydrafacial rejuvenation',
        category: 'Skin',
        preferredBranchId: 'juhu',
      );

      final responseToAccept = request.responses.first;
      final success = await service.chooseStylist(request.id, responseToAccept.id);
      expect(success, isTrue);

      final handoff = await service.getBookingHandoffContext(request.id);
      expect(handoff['requestId'], equals(request.id));
      expect(handoff['category'], equals('Skin'));
      expect(handoff['branchId'], equals('juhu'));
    });
  });
}
