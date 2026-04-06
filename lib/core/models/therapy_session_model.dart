/// Therapy Session Model
/// Model untuk sesi terapi dan pembayaran
/// Matches backend API response format
class TherapySessionModel {
  final String id;
  final String childId;
  final String? therapistId;
  final DateTime schedule;
  final String paymentStatus; // PENDING, SUCCESS, FAILED, CANCELLED
  final String therapyType;
  final bool isActive;
  final String? transactionId;
  final String? paymentUrl;
  final String? transactionToken;
  final int? amount;
  final ChildInfo? child;
  final TherapistInfo? therapist;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TherapySessionModel({
    required this.id,
    required this.childId,
    this.therapistId,
    required this.schedule,
    required this.paymentStatus,
    required this.therapyType,
    required this.isActive,
    this.transactionId,
    this.paymentUrl,
    this.transactionToken,
    this.amount,
    this.child,
    this.therapist,
    this.createdAt,
    this.updatedAt,
  });

  // Get payment status color
  String get paymentStatusColor {
    switch (paymentStatus) {
      case 'PENDING':
        return 'FFB74D'; // Orange
      case 'SUCCESS':
        return '4CAF50'; // Green
      case 'FAILED':
      case 'CANCELLED':
        return 'EF4444'; // Red
      default:
        return '94A3B8'; // Grey
    }
  }

  // Get payment status display text
  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'PENDING':
        return 'Menunggu Pembayaran';
      case 'SUCCESS':
        return 'Lunas';
      case 'FAILED':
        return 'Gagal';
      case 'CANCELLED':
        return 'Dibatalkan';
      default:
        return paymentStatus;
    }
  }

  // Check if session is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return schedule.isAfter(now);
  }

  // Check if session is today
  bool get isToday {
    final now = DateTime.now();
    return schedule.year == now.year &&
        schedule.month == now.month &&
        schedule.day == now.day;
  }

  // Get formatted schedule
  String get formattedSchedule {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${schedule.day} ${months[schedule.month]} ${schedule.year}, ${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}';
  }

  // Convert from JSON - matches backend response format
  factory TherapySessionModel.fromJson(Map<String, dynamic> json) {
    return TherapySessionModel(
      id: json['id'] ?? '',
      childId: json['childId'] ?? json['child_id'] ?? '',
      therapistId: json['therapistId'] ?? json['therapist_id'],
      schedule: json['schedule'] != null
          ? DateTime.parse(json['schedule'])
          : DateTime.now(),
      paymentStatus: json['paymentStatus'] ?? json['payment_status'] ?? 'PENDING',
      therapyType: json['therapyType'] ?? json['therapy_type'] ?? '',
      isActive: json['isActive'] ?? json['is_active'] ?? false,
      transactionId: json['transactionId'] ?? json['transaction_id'],
      paymentUrl: json['paymentUrl'] ?? json['payment_url'],
      transactionToken: json['transactionToken'] ?? json['transaction_token'],
      amount: json['amount'],
      child: json['child'] != null ? ChildInfo.fromJson(json['child']) : null,
      therapist: json['therapist'] != null
          ? TherapistInfo.fromJson(json['therapist'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Convert to JSON - for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'therapistId': therapistId,
      'schedule': schedule.toIso8601String(),
      'paymentStatus': paymentStatus,
      'therapyType': therapyType,
      'isActive': isActive,
      'transactionId': transactionId,
      'paymentUrl': paymentUrl,
      'transactionToken': transactionToken,
      'amount': amount,
      'child': child?.toJson(),
      'therapist': therapist?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Child Info (nested in therapy session)
class ChildInfo {
  final String id;
  final String name;

  ChildInfo({required this.id, required this.name});

  factory ChildInfo.fromJson(Map<String, dynamic> json) {
    return ChildInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

/// Therapist Info (nested in therapy session)
class TherapistInfo {
  final String? id;
  final String name;
  final String? email;

  TherapistInfo({this.id, required this.name, this.email});

  factory TherapistInfo.fromJson(Map<String, dynamic> json) {
    return TherapistInfo(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
