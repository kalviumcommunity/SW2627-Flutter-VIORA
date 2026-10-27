class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.data = const {},
    required this.createdAt,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      data: data,
      createdAt: createdAt,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? 'VIORA Notification',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      isRead: json['isRead'] == true || json['read'] == true,
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : {},
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static final List<NotificationItem> sampleNotifications = [
    NotificationItem(
      id: 'notif-01',
      title: 'Stylist Proposal Received',
      message: 'Julian Vance responded to your Balayage inspiration request with an estimated proposal.',
      type: 'inspiration_response',
      isRead: false,
      data: {'requestId': 'INSP-0001', 'stylistId': 's1'},
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    NotificationItem(
      id: 'notif-02',
      title: 'Appointment Confirmed',
      message: 'Your reservation for Glass Skin Hydrafacial at Khar West is confirmed for Saturday, 2:00 PM.',
      type: 'booking_confirmed',
      isRead: false,
      data: {'appointmentId': 'VIO-89421'},
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    NotificationItem(
      id: 'notif-03',
      title: 'Share Your Experience',
      message: 'How was your recent Brown Ombre Cat Eye service with Jessica? Tap to share your rating.',
      type: 'review_alert',
      isRead: true,
      data: {'appointmentId': 'VIO-78102', 'stylistId': 's3'},
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
