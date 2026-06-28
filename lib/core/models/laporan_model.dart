class LaporanModel {
  final String id;
  final String terapisId;
  final String patientId;
  final String patientName;
  final String patientAvatar;
  final String status;
  final String summary;
  final String date;

  LaporanModel({
    required this.id,
    required this.terapisId,
    required this.patientId,
    required this.patientName,
    required this.patientAvatar,
    required this.status,
    required this.summary,
    required this.date,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      id: json['id'] ?? '',
      terapisId: json['terapis_id'] ?? '',
      patientId: json['patient_id'] ?? '',
      patientName: json['patient_name'] ?? '',
      patientAvatar: json['patient_avatar'] ?? '',
      status: json['status'] ?? '',
      summary: json['summary'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'terapis_id': terapisId,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_avatar': patientAvatar,
      'status': status,
      'summary': summary,
      'date': date,
    };
  }
}
