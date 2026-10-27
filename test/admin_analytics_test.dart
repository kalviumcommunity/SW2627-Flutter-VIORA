import 'package:flutter_test/flutter_test.dart';
import 'package:viora_salon_app/services/analytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Person 3 — Admin Analytics & Business Intelligence Tests', () {
    final service = AnalyticsService();

    test('1. Overview KPIs return gross revenue, total reservations, and customers', () async {
      final overview = await service.getOverview();
      expect(overview.totalBookings, greaterThan(0));
      expect(overview.completedBookings, greaterThan(0));
      expect(overview.totalRevenue, greaterThan(100000));
      expect(overview.totalCustomers, greaterThan(0));
      expect(overview.retentionRate, greaterThan(0.0));
    });

    test('2. Branch performance returns ranked branches in Mumbai with revenue', () async {
      final branches = await service.getBranchPerformance();
      expect(branches.isNotEmpty, isTrue);
      expect(branches.any((b) => b.name.contains('Khar West')), isTrue);
      expect(branches.first.revenue, greaterThan(0.0));
      expect(branches.first.totalBookings, greaterThan(0));
    });

    test('3. Stylist leaderboard ranks stylists by rating and revenue generation', () async {
      final stylists = await service.getStylistPerformance();
      expect(stylists.isNotEmpty, isTrue);
      expect(stylists.first.name, equals('Julian Vance'));
      expect(stylists.first.rating, greaterThan(4.8));
      expect(stylists.first.revenue, greaterThan(50000.0));
    });

    test('4. Popular services and trending looks track customer demand', () async {
      final services = await service.getPopularServices();
      expect(services.isNotEmpty, isTrue);
      expect(services.first.bookingsCount, greaterThan(0));

      final looks = await service.getPopularLooks();
      expect(looks.isNotEmpty, isTrue);
      expect(looks.first.requestsCount, greaterThan(0));
    });

    test('5. Joel Customer Intelligence retention rate matches overall metrics', () async {
      final overview = await service.getOverview();
      // Retention calculation: returningCustomers / totalCustomers * 100
      final expectedMinRetention = (overview.returningCustomers / overview.totalCustomers) * 100;
      expect(overview.retentionRate, closeTo(expectedMinRetention, 1.0));
    });
  });
}
