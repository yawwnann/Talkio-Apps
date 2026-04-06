/// Progress Upload Model
/// Model untuk upload foto/video perkembangan anak
/// Matches backend API response format
class ProgressUploadModel {
  final String id;
  final String childId;
  final String fileUrl;
  final String? parentNotes;
  final String? therapistEvaluation;
  final String? fileType; // image, video
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProgressUploadModel({
    required this.id,
    required this.childId,
    required this.fileUrl,
    this.parentNotes,
    this.therapistEvaluation,
    this.fileType,
    required this.createdAt,
    this.updatedAt,
  });

  // Check if file is image
  bool get isImage {
    if (fileType != null) return fileType == 'image';
    final ext = fileUrl.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
  }

  // Check if file is video
  bool get isVideo {
    if (fileType != null) return fileType == 'video';
    final ext = fileUrl.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'webm'].contains(ext);
  }

  // Check if has therapist evaluation
  bool get hasEvaluation => therapistEvaluation != null && therapistEvaluation!.isNotEmpty;

  // Get formatted date
  String get formattedDate {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${createdAt.day} ${months[createdAt.month]} ${createdAt.year}';
  }

  // Convert from JSON - matches backend response format
  factory ProgressUploadModel.fromJson(Map<String, dynamic> json) {
    String? detectedType;
    final url = json['fileUrl'] ?? json['file_url'] ?? '';
    if (url.isNotEmpty) {
      final ext = url.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
        detectedType = 'image';
      } else if (['mp4', 'mov', 'avi', 'webm'].contains(ext)) {
        detectedType = 'video';
      }
    }

    return ProgressUploadModel(
      id: json['id'] ?? '',
      childId: json['childId'] ?? json['child_id'] ?? '',
      fileUrl: json['fileUrl'] ?? json['file_url'] ?? '',
      parentNotes: json['parentNotes'] ?? json['parent_notes'],
      therapistEvaluation: json['therapistEvaluation'] ?? json['therapist_evaluation'],
      fileType: json['fileType'] ?? json['file_type'] ?? detectedType,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'fileUrl': fileUrl,
      'parentNotes': parentNotes,
      'therapistEvaluation': therapistEvaluation,
      'fileType': fileType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ProgressUploadModel(id: $id, childId: $childId, fileUrl: $fileUrl)';
  }
}
