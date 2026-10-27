import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/analytics_model.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  /// Admin KPI overview
  Future<AdminAnalyticsOverview> getOverview() async {
    try {
      final response = await ApiClient().get('/admin/analytics/overview');
      if (response['success'] == true && response['overview'] is Map<String, dynamic>) {
        return AdminAnalyticsOverview.fromJson(response['overview'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Overview fallback: $e');
    }
    return AdminAnalyticsOverview.sampleOverview;
  }

  /// Branch-wise performance table
  Future<List<BranchPerformance>> getBranchPerformance() async {
    try {
      final response = await ApiClient().get('/admin/analytics/branches');
      if (response['success'] == true && response['branches'] is List) {
        final list = (response['branches'] as List)
            .map((e) => BranchPerformance.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Branches fallback: $e');
    }
    return BranchPerformance.sampleBranches;
  }

  /// Stylist performance & ratings ranking
  Future<List<StylistPerformance>> getStylistPerformance() async {
    try {
      final response = await ApiClient().get('/admin/analytics/stylists');
      if (response['success'] == true && response['stylists'] is List) {
        final list = (response['stylists'] as List)
            .map((e) => StylistPerformance.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Stylists fallback: $e');
    }
    return StylistPerformance.sampleStylists;
  }

  /// Popular services ranked by bookings
  Future<List<PopularService>> getPopularServices() async {
    try {
      final response = await ApiClient().get('/admin/analytics/services');
      if (response['success'] == true && response['services'] is List) {
        final list = (response['services'] as List)
            .map((e) => PopularService.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Services fallback: $e');
    }
    return PopularService.sampleServices;
  }

  /// Popular looks ranked by requests
  Future<List<PopularLook>> getPopularLooks() async {
    try {
      final response = await ApiClient().get('/admin/analytics/looks');
      if (response['success'] == true && response['looks'] is List) {
        final list = (response['looks'] as List)
            .map((e) => PopularLook.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Looks fallback: $e');
    }
    return PopularLook.sampleLooks;
  }
}
