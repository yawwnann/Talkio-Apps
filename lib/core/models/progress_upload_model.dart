class ProgressUploadModel {
  final String id;
  final String childId;
  final String fileUrl;
  final String? cloudinaryPublicId;
  final String? parentNotes;
  final String? therapistEvaluation;
  final String? fileType; // image, video, audio
  final int? duration;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProgressUploadModel({
    required this.id,
    required this.childId,
    required this.fileUrl,
    this.cloudinaryPublicId,
    this.parentNotes,
    this.therapistEvaluation,
    this.fileType,
    this.duration,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isImage {
    if (fileType != null) return fileType == 'image';
    final ext = fileUrl.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
  }

  bool get isVideo {
    if (fileType != null) return fileType == 'video';
    final ext = fileUrl.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'webm'].contains(ext);
  }

  bool get isAudio {
    if (fileType != null) return fileType == 'audio';
    final ext = fileUrl.split('.').last.toLowerCase();
    return ['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(ext);
  }

  bool get hasEvaluation => therapistEvaluation != null && therapistEvaluation!.isNotEmpty;

  String get formattedDate {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${createdAt.day} ${months[createdAt.month]} ${createdAt.year}';
  }

  String get formattedDateTime {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '${createdAt.day} ${months[createdAt.month]} ${createdAt.year}, $hour:$minute';
  }

  String get durationLabel {
    if (duration == null) return '';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  factory ProgressUploadModel.fromJson(Map<String, dynamic> json) {
    String? detectedType;
    final url = (json['fileUrl'] ?? json['file_url'] ?? '') as String;
    if (url.isNotEmpty) {
      final ext = url.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
        detectedType = 'image';
      } else if (['mp4', 'mov', 'avi', 'webm'].contains(ext)) {
        detectedType = 'video';
      } else if (['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(ext)) {
        detectedType = 'audio';
      }
    }

    return ProgressUploadModel(
      id: json['id'] ?? '',
      childId: json['childId'] ?? json['child_id'] ?? '',
      fileUrl: url,
      cloudinaryPublicId: json['cloudinaryPublicId'] ?? json['cloudinary_public_id'],
      parentNotes: json['parentNotes'] ?? json['parent_notes'],
      therapistEvaluation: json['therapistEvaluation'] ?? json['therapist_evaluation'],
      fileType: json['fileType'] ?? json['file_type'] ?? detectedType,
      duration: json['duration'] != null ? (json['duration'] as num).toInt() : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'fileUrl': fileUrl,
      'cloudinaryPublicId': cloudinaryPublicId,
      'parentNotes': parentNotes,
      'therapistEvaluation': therapistEvaluation,
      'fileType': fileType,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ProgressUploadModel(id: $id, childId: $childId, fileType: $fileType, fileUrl: $fileUrl)';
  }
}
