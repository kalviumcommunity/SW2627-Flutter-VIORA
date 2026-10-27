import 'package:flutter_test/flutter_test.dart';
import 'package:viora_salon_app/services/notification_service.dart';
import 'package:viora_salon_app/services/stylist_service.dart';
import 'package:viora_salon_app/services/inspiration_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Person 3 — Notifications & Stylist Portal Unit Tests', () {
    final notifService = NotificationService();
    final stylistService = StylistService();
    final inspirationService = InspirationService();

    test('1. Notification service loads notifications with unread tracking', () async {
      final notifs = await notifService.getNotifications();
      expect(notifs.isNotEmpty, isTrue);
      expect(notifService.unreadCount, greaterThanOrEqualTo(0));
    });

    test('2. Marking single notification as read updates local state', () async {
      final notifs = await notifService.getNotifications();
      final target = notifs.firstWhere((n) => !n.isRead, orElse: () => notifs.first);

      final success = await notifService.markAsRead(target.id);
      expect(success, isTrue);
    });

    test('3. Marking all notifications as read resets unread count to 0', () async {
      await notifService.markAllAsRead();
      expect(notifService.unreadCount, equals(0));
    });

    test('4. Stylist portfolio service loads portfolio items with categories', () async {
      final portfolio = await stylistService.getStylistPortfolio('s1');
      expect(portfolio.isNotEmpty, isTrue);
      expect(portfolio.first.category.isNotEmpty, isTrue);
      expect(portfolio.first.likesCount, greaterThanOrEqualTo(0));
    });

    test('5. Stylist can publish new creation to visual portfolio', () async {
      final item = await stylistService.createPortfolioItem(
        title: 'Rose Gold Gloss & Blowout',
        category: 'Coloring',
        imageUrl: 'assets/images/hair_colour.png',
        description: 'Pastel toner formula on level 10 blonde with botanical gloss shine.',
        tags: ['Rose Gold', 'Gloss', 'Blowout'],
      );

      expect(item.id.isNotEmpty, isTrue);
      expect(item.title, equals('Rose Gold Gloss & Blowout'));
      expect(item.tags.contains('Rose Gold'), isTrue);
    });

    test('6. Stylist can respond to customer inspiration request with bespoke proposal', () async {
      final response = await inspirationService.submitStylistResponse(
        requestId: 'INSP-1001',
        stylistId: 's1',
        stylistName: 'Julian Vance',
        stylistAvatar: 'assets/images/avatar_christian.png',
        stylistRole: 'Art Director',
        proposedTechnique: 'Custom French balayage with Olaplex molecular bond builder',
        estimatedPrice: 7200,
        estimatedDuration: '120 mins',
      );

      expect(response.id.isNotEmpty, isTrue);
      expect(response.estimatedCost, equals(7200.0));
      expect(response.stylistName, equals('Julian Vance'));
    });
  });
}
