import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/progress_upload_model.dart';
import '../../../core/services/api_service.dart';

class ProgressUploadState {
  final List<ProgressUploadModel> uploads;
  final bool isLoading;
  final String? error;
  final bool isUploading;
  final double? uploadProgress;

  const ProgressUploadState({
    this.uploads = const [],
    this.isLoading = false,
    this.error,
    this.isUploading = false,
    this.uploadProgress,
  });

  ProgressUploadState copyWith({
    List<ProgressUploadModel>? uploads,
    bool? isLoading,
    String? error,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return ProgressUploadState(
      uploads: uploads ?? this.uploads,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

class ProgressUploadNotifier extends StateNotifier<ProgressUploadState> {
  final ApiService _apiService;

  ProgressUploadNotifier(this._apiService) : super(const ProgressUploadState());

  Future<bool> uploadProgress({
    required String childId,
    required File file,
    String? notes,
  }) async {
    state = state.copyWith(isUploading: true, error: null, uploadProgress: 0);

    try {
      final isVideo = file.path.endsWith('.mp4') ||
          file.path.endsWith('.mov') ||
          file.path.endsWith('.avi') ||
          file.path.endsWith('.webm');
      final isAudio = file.path.endsWith('.mp3') ||
          file.path.endsWith('.wav') ||
          file.path.endsWith('.aac') ||
          file.path.endsWith('.m4a') ||
          file.path.endsWith('.ogg');
      final fileType = isVideo ? 'video' : (isAudio ? 'audio' : 'image');

      // Step 1: Upload to Cloudinary via backend
      print('🔄 [ProgressUpload] Uploading file via backend...');
      final cloudinaryResponse = await _apiService.uploadToCloudinary(
        file: file,
        childId: childId,
        onProgress: (sent, total) {
          if (total > 0) {
            final progress = (sent / total) * 100;
            state = state.copyWith(uploadProgress: progress);
          }
        },
      );

      state = state.copyWith(uploadProgress: 50);

      if (cloudinaryResponse.statusCode != 200) {
        throw Exception('Failed to upload file to Cloudinary');
      }

      final cloudinaryData = cloudinaryResponse.data;
      if (cloudinaryData is! Map<String, dynamic> || cloudinaryData['status'] != 'success') {
        throw Exception(cloudinaryData['message'] ?? 'Failed to upload file');
      }

      final cloudinaryResult = cloudinaryData['data'] as Map<String, dynamic>;
      final secureUrl = cloudinaryResult['secureUrl'] as String;
      final publicId = cloudinaryResult['publicId'] as String;
      final duration = cloudinaryResult['duration'] as int?;

      // Step 2: Save metadata to backend
      print('🔄 [ProgressUpload] Saving progress metadata...');
      state = state.copyWith(uploadProgress: 75);

      final response = await _apiService.uploadProgress(
        childId: childId,
        fileUrl: secureUrl,
        cloudinaryPublicId: publicId,
        fileType: fileType,
        duration: duration,
        notes: notes,
      );

      state = state.copyWith(uploadProgress: 100);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final newUpload = ProgressUploadModel.fromJson(data['data']);
          state = state.copyWith(
            uploads: [newUpload, ...state.uploads],
            isUploading: false,
            uploadProgress: null,
          );
          return true;
        } else {
          state = state.copyWith(
            error: (data is Map ? data['message'] : null) ?? 'Gagal menyimpan progress',
            isUploading: false,
            uploadProgress: null,
          );
          return false;
        }
      }

      state = state.copyWith(
        error: 'Gagal menyimpan progress',
        isUploading: false,
        uploadProgress: null,
      );
      return false;
    } catch (e) {
      print('🔄 [ProgressUpload] Error: $e');
      state = state.copyWith(
        error: e.toString(),
        isUploading: false,
        uploadProgress: null,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clear() {
    state = const ProgressUploadState();
  }
}

final progressUploadProvider =
    StateNotifierProvider<ProgressUploadNotifier, ProgressUploadState>((ref) {
  return ProgressUploadNotifier(ApiService());
});
