import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'inspiration_responses_screen.dart';
import 'my_appointments_screen.dart';
import 'submit_review_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final list = await _notificationService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    if (mounted) {
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('All notifications marked as read.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleNotificationTap(NotificationItem item) async {
    if (!item.isRead) {
      await _notificationService.markAsRead(item.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == item.id);
        if (index != -1) {
          _notifications[index] = item.copyWith(isRead: true);
        }
      });
    }

    if (!mounted) return;

    if (item.type == 'inspiration_response') {
      final reqId = item.data['requestId']?.toString();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => InspirationResponsesScreen(requestId: reqId),
        ),
      );
    } else if (item.type == 'review_alert') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SubmitReviewScreen(
            appointmentId: item.data['appointmentId']?.toString(),
            stylistId: item.data['stylistId']?.toString(),
          ),
        ),
      );
    } else if (item.type == 'booking_confirmed') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MyAppointmentsScreen(),
        ),
      );
    }
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'inspiration_response':
        return Icons.auto_awesome;
      case 'booking_confirmed':
        return Icons.event_available;
      case 'review_alert':
        return Icons.star_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.editorialTitle(fontSize: 22).copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _loadNotifications,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        return _buildNotificationCard(notif);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_outlined, size: 34, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              'All Caught Up',
              style: AppTextStyles.editorialTitle(fontSize: 22),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have no pending notifications. Reservation confirmations and bespoke stylist responses will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notif) {
    return InkWell(
      onTap: () => _handleNotificationTap(notif),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.surface : const Color(0xFFFBF7F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.4),
            width: notif.isRead ? 1.0 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notif.isRead ? AppColors.background : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForType(notif.type),
                size: 22,
                color: notif.isRead ? AppColors.textSecondary : AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimestamp(notif.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: notif.isRead ? AppColors.textSecondary : const Color(0xFF4A4540),
                      height: 1.35,
                    ),
                  ),
                  if (!notif.isRead) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Unread',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
