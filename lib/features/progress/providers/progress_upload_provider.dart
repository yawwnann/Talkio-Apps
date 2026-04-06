import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/progress_upload_model.dart';
import '../../../core/services/api_service.dart';

/// Progress Upload State
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

/// Progress Upload Notifier
class ProgressUploadNotifier extends StateNotifier<ProgressUploadState> {
  final ApiService _apiService;

  ProgressUploadNotifier(this._apiService) : super(const ProgressUploadState());

  /// Upload progress (photo/video)
  Future<bool> uploadProgress({
    required String childId,
    required File file,
    String? notes,
  }) async {
    state = state.copyWith(isUploading: true, error: null, uploadProgress: 0);

    try {
      // Note: For actual upload progress tracking, you'd use Dio's onSendProgress
      // For now, we'll simulate it
      final response = await _apiService.uploadProgress(
        childId: childId,
        file: file,
        notes: notes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final newUpload = ProgressUploadModel.fromJson(data['data']);

          state = state.copyWith(
            uploads: [newUpload, ...state.uploads],
            isUploading: false,
            uploadProgress: 100,
          );
          return true;
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal mengupload progress',
            isUploading: false,
            uploadProgress: null,
          );
          return false;
        }
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isUploading: false,
        uploadProgress: null,
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear state
  void clear() {
    state = const ProgressUploadState();
  }
}

/// Progress Upload Provider
final progressUploadProvider =
    StateNotifierProvider<ProgressUploadNotifier, ProgressUploadState>((ref) {
  return ProgressUploadNotifier(ApiService());
});
