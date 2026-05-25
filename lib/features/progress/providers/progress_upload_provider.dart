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
      final response = await _apiService.uploadProgress(
        childId: childId,
        file: file,
        notes: notes,
        onProgress: (sent, total) {
          if (total > 0) {
            final progress = (sent / total) * 100;
            state = state.copyWith(uploadProgress: progress);
          }
        },
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
            error: (data is Map ? data['message'] : null) ?? 'Gagal mengupload progress',
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
