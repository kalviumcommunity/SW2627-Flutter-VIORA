import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/portfolio_model.dart';
import '../models/review_model.dart';

class StylistService {
  static final StylistService _instance = StylistService._internal();
  factory StylistService() => _instance;
  StylistService._internal();

  final List<PortfolioItem> _localPortfolio = [];

  /// Alias for getStylistPortfolio
  Future<List<PortfolioItem>> getPortfolio(String stylistId) => getStylistPortfolio(stylistId);

  /// Get portfolio for public stylist profile
  Future<List<PortfolioItem>> getStylistPortfolio(String stylistId) async {
    try {
      final response = await ApiClient().get('/stylists/$stylistId/portfolio');
      if (response['success'] == true && response['portfolio'] is List) {
        final list = (response['portfolio'] as List)
            .map((e) => PortfolioItem.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[StylistService] Stylist portfolio fallback: $e');
    }

    final filtered = PortfolioItem.samplePortfolio.where((p) => p.stylistId == stylistId).toList();
    return filtered.isNotEmpty ? filtered : PortfolioItem.samplePortfolio;
  }

  /// Get authenticated stylist's own portfolio
  Future<List<PortfolioItem>> getMyPortfolio() async {
    try {
      final response = await ApiClient().get('/stylists/me/portfolio');
      if (response['success'] == true && response['portfolio'] is List) {
        final list = (response['portfolio'] as List)
            .map((e) => PortfolioItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _localPortfolio.clear();
        _localPortfolio.addAll(list);
        return list;
      }
    } catch (e) {
      debugPrint('[StylistService] My portfolio fallback: $e');
    }

    if (_localPortfolio.isEmpty) {
      _localPortfolio.addAll(PortfolioItem.samplePortfolio);
    }
    return _localPortfolio;
  }

  /// Alias for addPortfolioItem
  Future<PortfolioItem> addPortfolioItem({
    required String stylistId,
    required String title,
    required String description,
    required String imageUrl,
    required String category,
    List<String> tags = const [],
  }) {
    return createPortfolioItem(
      title: title,
      category: category,
      imageUrl: imageUrl,
      description: description,
      tags: tags,
    );
  }

  /// Add new work to stylist portfolio
  Future<PortfolioItem> createPortfolioItem({
    required String title,
    required String category,
    required String imageUrl,
    required String description,
    List<String> tags = const [],
    String? serviceName,
  }) async {
    try {
      final response = await ApiClient().post('/stylists/me/portfolio', body: {
        'title': title,
        'category': category,
        'imageUrl': imageUrl,
        'description': description,
        'tags': tags,
        if (serviceName != null) 'serviceName': serviceName,
      });

      if (response['success'] == true && response['item'] is Map<String, dynamic>) {
        final item = PortfolioItem.fromJson(response['item'] as Map<String, dynamic>);
        _localPortfolio.insert(0, item);
        return item;
      }
    } catch (e) {
      debugPrint('[StylistService] Create portfolio fallback: $e');
    }

    final newItem = PortfolioItem(
      id: 'port-${DateTime.now().millisecondsSinceEpoch}',
      stylistId: 's1',
      title: title,
      category: category,
      imageUrl: imageUrl,
      description: description,
      tags: tags,
      serviceName: serviceName,
      likesCount: 1,
      createdAt: DateTime.now(),
    );
    _localPortfolio.insert(0, newItem);
    return newItem;
  }

  /// Delete portfolio item
  Future<bool> deletePortfolioItem(String itemId) async {
    try {
      final response = await ApiClient().delete('/stylists/me/portfolio/$itemId');
      if (response['success'] == true) {
        _localPortfolio.removeWhere((p) => p.id == itemId);
        return true;
      }
    } catch (e) {
      debugPrint('[StylistService] Delete portfolio fallback: $e');
    }

    _localPortfolio.removeWhere((p) => p.id == itemId);
    return true;
  }

  /// Get stylist review statistics
  Future<StylistReviewStats> getStylistStats(String stylistId) async {
    try {
      final response = await ApiClient().get('/stylists/$stylistId/reviews/stats');
      if (response['success'] == true && response['stats'] is Map<String, dynamic>) {
        return StylistReviewStats.fromJson(response['stats'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[StylistService] Stats fallback: $e');
    }
    return StylistReviewStats.sampleStats;
  }
}
