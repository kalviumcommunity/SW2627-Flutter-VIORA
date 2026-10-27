import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/review_model.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final List<ReviewItem> _localReviews = [];

  /// Get appointments eligible for customer review
  Future<List<EligibleAppointment>> getEligibleAppointments() async {
    try {
      final response = await ApiClient().get('/reviews/eligible-appointments');
      if (response['success'] == true && response['appointments'] is List) {
        final list = (response['appointments'] as List)
            .map((e) => EligibleAppointment.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[ReviewService] Eligible appointments fallback: $e');
    }

    return EligibleAppointment.sampleEligible;
  }

  /// Submit a customer review
  Future<ReviewItem> submitReview({
    required String appointmentId,
    required String stylistId,
    required double rating,
    required double lookRating,
    required double stylistRating,
    required String comments,
    String? serviceName,
    List<String> photos = const [],
  }) async {
    final overallInt = rating.round();
    final lookInt = lookRating.round();
    final stylistInt = stylistRating.round();

    try {
      final response = await ApiClient().post('/reviews', body: {
        'appointmentId': appointmentId,
        'stylistId': stylistId,
        'rating': overallInt,
        'lookRating': lookInt,
        'stylistRating': stylistInt,
        'comments': comments,
        if (serviceName != null) 'serviceName': serviceName,
        'photos': photos,
      });

      if (response['success'] == true && response['review'] is Map<String, dynamic>) {
        final item = ReviewItem.fromJson(response['review'] as Map<String, dynamic>);
        _localReviews.insert(0, item);
        return item;
      }
    } catch (e) {
      debugPrint('[ReviewService] Submit review fallback: $e');
    }

    final fallback = ReviewItem(
      id: 'REV-${DateTime.now().millisecondsSinceEpoch}',
      appointmentId: appointmentId,
      customerId: 'CUST-0031',
      userName: 'Aria Montgomery',
      stylistId: stylistId,
      stylistName: stylistId == 's1' ? 'Julian Vance' : 'Sarah Kothari',
      serviceName: serviceName ?? 'Signature Atelier Treatment',
      overallRating: overallInt,
      lookRating: lookInt,
      stylistRating: stylistInt,
      comments: comments,
      photos: photos,
      status: 'published',
      createdAt: DateTime.now(),
    );

    _localReviews.insert(0, fallback);
    return fallback;
  }

  /// Get stylist reviews list
  Future<List<ReviewItem>> getStylistReviews(String stylistId) async {
    try {
      final response = await ApiClient().get('/reviews/stylist/$stylistId');
      if (response['success'] == true && response['reviews'] is List) {
        final list = (response['reviews'] as List)
            .map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[ReviewService] Stylist reviews fallback: $e');
    }

    final filtered = ReviewItem.sampleReviews.where((r) => r.stylistId == stylistId).toList();
    return filtered.isNotEmpty ? filtered : ReviewItem.sampleReviews;
  }

  /// Get stylist reviews with stats bundled
  Future<Map<String, dynamic>> getStylistReviewsWithStats(String stylistId) async {
    final reviews = await getStylistReviews(stylistId);
    final stats = await getStylistStats(stylistId);
    return {'reviews': reviews, 'stats': stats};
  }

  /// Get stylist stats
  Future<StylistReviewStats> getStylistStats(String stylistId) async {
    try {
      final response = await ApiClient().get('/reviews/stylist/$stylistId/stats');
      if (response['success'] == true && response['stats'] is Map<String, dynamic>) {
        return StylistReviewStats.fromJson(response['stats'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[ReviewService] Stylist stats fallback: $e');
    }

    return StylistReviewStats.sampleStats;
  }

  /// Get customer's submitted reviews
  Future<List<ReviewItem>> getMyReviews() async {
    try {
      final response = await ApiClient().get('/reviews/my-reviews');
      if (response['success'] == true && response['reviews'] is List) {
        final list = (response['reviews'] as List)
            .map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[ReviewService] My reviews fallback: $e');
    }

    if (_localReviews.isEmpty) {
      _localReviews.addAll(ReviewItem.sampleReviews);
    }
    return _localReviews;
  }
}
