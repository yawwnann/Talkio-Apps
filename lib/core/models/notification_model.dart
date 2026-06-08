// Admin notification event types
class AdminNotificationType {
  static const String therapistRegistration = 'ADMIN_THERAPIST_REGISTRATION';
  static const String paymentSuccess = 'ADMIN_PAYMENT_SUCCESS';
  static const String paymentFailed = 'ADMIN_PAYMENT_FAILED';
  static const String newReport = 'ADMIN_NEW_REPORT';
  static const String highRiskDiagnosis = 'ADMIN_HIGH_RISK_DIAGNOSIS';
  static const String newBooking = 'ADMIN_NEW_BOOKING';
  static const String sessionCompleted = 'ADMIN_SESSION_COMPLETED';

  static const List<String> all = [
    therapistRegistration,
    paymentSuccess,
    paymentFailed,
    newReport,
    highRiskDiagnosis,
    newBooking,
    sessionCompleted,
  ];

  static bool isAdminType(String type) => all.contains(type.toUpperCase());
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String priority; // HIGH, MEDIUM, LOW
  final bool isRead;
  final String? childId;
  final String? sessionId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = 'LOW',
    required this.isRead,
    this.childId,
    this.sessionId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] ?? 'INFO') as String;
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: type,
      priority: json['priority'] ?? _defaultPriority(type),
      isRead: json['isRead'] ?? false,
      childId: json['childId'] ?? json['child_id'],
      sessionId: json['sessionId'] ?? json['session_id'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static String _defaultPriority(String type) {
    switch (type.toUpperCase()) {
      case 'ADMIN_THERAPIST_REGISTRATION':
      case 'ADMIN_PAYMENT_SUCCESS':
      case 'ADMIN_HIGH_RISK_DIAGNOSIS':
        return 'HIGH';
      case 'ADMIN_PAYMENT_FAILED':
      case 'ADMIN_NEW_REPORT':
        return 'MEDIUM';
      case 'ADMIN_NEW_BOOKING':
      case 'ADMIN_SESSION_COMPLETED':
        return 'LOW';
      default:
        return 'LOW';
    }
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? priority,
    bool? isRead,
    String? childId,
    String? sessionId,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      childId: childId ?? this.childId,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}