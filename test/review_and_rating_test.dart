import 'package:flutter_test/flutter_test.dart';
import 'package:viora_salon_app/services/review_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Person 3 — Reviews, Ratings & Eligible Appointments Unit Tests', () {
    final service = ReviewService();

    test('1. Eligible appointments returns completed visits with stylist details', () async {
      final list = await service.getEligibleAppointments();
      expect(list.isNotEmpty, isTrue);
      expect(list.first.appointmentId.isNotEmpty, isTrue);
      expect(list.first.stylistName.isNotEmpty, isTrue);
      expect(list.first.serviceName.isNotEmpty, isTrue);
    });

    test('2. Submitting review parses 3-tier rating scores and comments', () async {
      final review = await service.submitReview(
        appointmentId: 'VIO-89421',
        stylistId: 's1',
        rating: 5.0,
        lookRating: 5.0,
        stylistRating: 4.0,
        comments: 'Julian transformed my hair with incredible balayage technique. Truly luxury experience.',
        serviceName: 'Artisan French Balayage',
      );

      expect(review.id.isNotEmpty, isTrue);
      expect(review.overallRating, equals(5));
      expect(review.lookRating, equals(5));
      expect(review.stylistRating, equals(4));
      expect(review.stylistName, equals('Julian Vance'));
      expect(review.status, equals('published'));
    });

    test('3. Stylist reviews returns client testimonials with rating breakdowns', () async {
      final reviews = await service.getStylistReviews('s1');
      expect(reviews.isNotEmpty, isTrue);
      expect(reviews.first.userName.isNotEmpty, isTrue);
      expect(reviews.first.overallRating, greaterThanOrEqualTo(4));
    });

    test('4. Stylist stats scorecard computes average ratings and distribution', () async {
      final stats = await service.getStylistStats('s1');
      expect(stats.averageOverall, greaterThan(4.5));
      expect(stats.averageLook, greaterThan(4.5));
      expect(stats.averageStylist, greaterThan(4.5));
      expect(stats.ratingDistribution.containsKey(5), isTrue);
      expect(stats.totalReviews, greaterThan(0));
    });
  });
}
