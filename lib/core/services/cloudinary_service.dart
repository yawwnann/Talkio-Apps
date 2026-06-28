import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;
  final String? resourceType;
  final int? bytes;
  final int? duration; // in seconds (for video/audio)

  CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
    this.resourceType,
    this.bytes,
    this.duration,
  });
}

class CloudinaryService {
  final Dio _dio = Dio();

  String get _baseUrl =>
      'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}';

  Future<CloudinaryUploadResult> uploadFile({
    required File file,
    required String resourceType, // "image", "video", "raw"
    void Function(int sent, int total)? onProgress,
  }) async {
    final url = '$_baseUrl/$resourceType/upload';

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'upload_preset': AppConstants.cloudinaryUploadPreset,
    });

    final response = await _dio.post(
      url,
      data: formData,
      onSendProgress: onProgress,
    );

    final data = response.data as Map<String, dynamic>;

    return CloudinaryUploadResult(
      secureUrl: data['secure_url'] ?? '',
      publicId: data['public_id'] ?? '',
      resourceType: data['resource_type'] as String?,
      bytes: (data['bytes'] as num?)?.toInt(),
      duration: (data['duration'] as num?)?.toInt(),
    );
  }
}
