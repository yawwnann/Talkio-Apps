/// Jadwal Model
/// Model untuk jadwal terapi
class JadwalModel {
  final String id;
  final String anakId;
  final String terapisId;
  final String parentId;
  final DateTime scheduledDate;
  final String timeSlot; // "09:00-10:00"
  final String status; // scheduled, ongoing, completed, cancelled
  final String? notes;
  final String? sessionType; // online, offline
  final String? meetingLink;
  final String? childName;
  final String? therapistName;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  JadwalModel({
    required this.id,
    required this.anakId,
    required this.terapisId,
    required this.parentId,
    required this.scheduledDate,
    required this.timeSlot,
    required this.status,
    this.notes,
    this.sessionType,
    this.meetingLink,
    this.childName,
    this.therapistName,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return '#2196F3'; // Blue
      case 'ongoing':
        return '#FF9800'; // Orange
      case 'pending_confirmation':
        return '#F59E0B'; // Amber
      case 'completed':
        return '#4CAF50'; // Green
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }
  
  // Get status text
  String get statusText {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Terjadwal';
      case 'ongoing':
        return 'Sedang Berlangsung';
      case 'pending_confirmation':
        return 'Menunggu Konfirmasi';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }
  
  // Check if session is today
  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
           scheduledDate.month == now.month &&
           scheduledDate.day == now.day;
  }
  
  // Check if session is upcoming (within 24 hours)
  bool get isUpcoming {
    final now = DateTime.now();
    final difference = scheduledDate.difference(now);
    return difference.inHours <= 24 && difference.inHours > 0;
  }
  
  // Get formatted date and time
  String get formattedDateTime {
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${scheduledDate.day} ${months[scheduledDate.month]} ${scheduledDate.year}, $timeSlot';
  }
  
  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    // Determine timeSlot from schedule if time_slot is not provided
    String parsedTimeSlot = json['time_slot'] ?? '';
    if (parsedTimeSlot.isEmpty && json['schedule'] != null) {
      final date = DateTime.parse(json['schedule']).toLocal();
      parsedTimeSlot = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${(date.hour + 1).toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    return JadwalModel(
      id: json['id'] ?? '',
      anakId: json['anak_id'] ?? json['childId'] ?? '',
      terapisId: json['terapis_id'] ?? '',
      parentId: json['parent_id'] ?? '',
      scheduledDate: DateTime.parse(json['scheduled_date'] ?? json['schedule'] ?? DateTime.now().toIso8601String()).toLocal(),
      timeSlot: parsedTimeSlot,
      status: json['status'] ?? '',
      notes: json['notes'],
      sessionType: json['session_type'] ?? json['therapyType'],
      meetingLink: json['meeting_link'],
      childName: json['childName'],
      therapistName: json['therapistName'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'anak_id': anakId,
      'terapis_id': terapisId,
      'parent_id': parentId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'time_slot': timeSlot,
      'status': status,
      'notes': notes,
      'session_type': sessionType,
      'meeting_link': meetingLink,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Copy with new values
  JadwalModel copyWith({
    String? id,
    String? anakId,
    String? terapisId,
    String? parentId,
    DateTime? scheduledDate,
    String? timeSlot,
    String? status,
    String? notes,
    String? sessionType,
    String? meetingLink,
    String? childName,
    String? therapistName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JadwalModel(
      id: id ?? this.id,
      anakId: anakId ?? this.anakId,
      terapisId: terapisId ?? this.terapisId,
      parentId: parentId ?? this.parentId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      sessionType: sessionType ?? this.sessionType,
      meetingLink: meetingLink ?? this.meetingLink,
      childName: childName ?? this.childName,
      therapistName: therapistName ?? this.therapistName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  String toString() {
    return 'JadwalModel(id: $id, date: $formattedDateTime, status: $status)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is JadwalModel &&
        other.id == id &&
        other.anakId == anakId &&
        other.scheduledDate == scheduledDate &&
        other.timeSlot == timeSlot;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        anakId.hashCode ^
        scheduledDate.hashCode ^
        timeSlot.hashCode;
  }
}