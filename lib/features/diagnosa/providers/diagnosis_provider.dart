import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/diagnosis_model.dart';
import '../../../core/models/api_response_model.dart';
import '../../../core/services/api_service.dart';

/// Diagnosis State
class DiagnosisState {
  final List<DiagnosisModel> diagnoses;
  final DiagnosisModel? latestDiagnosis;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  const DiagnosisState({
    this.diagnoses = const [],
    this.latestDiagnosis,
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  DiagnosisState copyWith({
    List<DiagnosisModel>? diagnoses,
    DiagnosisModel? latestDiagnosis,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return DiagnosisState(
      diagnoses: diagnoses ?? this.diagnoses,
      latestDiagnosis: latestDiagnosis ?? this.latestDiagnosis,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Diagnosis Notifier
class DiagnosisNotifier extends StateNotifier<DiagnosisState> {
  final ApiService _apiService;

  DiagnosisNotifier(this._apiService) : super(const DiagnosisState());

  /// Get diagnosis history for a child
  Future<void> fetchDiagnosisHistory(String childId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getDiagnosisHistory(childId);

      if (response.statusCode == 200) {
        final data = response.data;
        List<DiagnosisModel> diagnoses = [];

        // Handle different response formats
        if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            diagnoses = (data['data'] as List)
                .map((json) => DiagnosisModel.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        } else if (data is List) {
          diagnoses = data
              .map((json) => DiagnosisModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        state = state.copyWith(
          diagnoses: diagnoses,
          latestDiagnosis: diagnoses.isNotEmpty ? diagnoses.first : null,
          isLoading: false,
        );
      } else {
        final msg = response.data is Map
            ? (response.data as Map)['message'] ?? 'Gagal memuat riwayat diagnosis'
            : 'Gagal memuat riwayat diagnosis';
        state = state.copyWith(error: msg.toString(), isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Create new diagnosis
  Future<bool> createDiagnosis({
    required String childId,
    required Map<String, String> answers,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final response = await _apiService.createDiagnosis(
        childId: childId,
        answers: answers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final newDiagnosis = DiagnosisModel.fromJson(data['data']);

          state = state.copyWith(
            latestDiagnosis: newDiagnosis,
            diagnoses: [newDiagnosis, ...state.diagnoses],
            isSubmitting: false,
          );
          return true;
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal membuat diagnosis',
            isSubmitting: false,
          );
          return false;
        }
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSubmitting: false,
      );
      return false;
    }
  }

  /// Get single diagnosis by ID
  Future<DiagnosisModel?> getDiagnosisById(String id) async {
    try {
      final response = await _apiService.getDiagnosisById(id);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return DiagnosisModel.fromJson(data['data']);
        }
        if (data is Map<String, dynamic> && data['status'] == 'success' && data['data'] is Map<String, dynamic>) {
          return DiagnosisModel.fromJson(data['data']);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear state
  void clear() {
    state = const DiagnosisState();
  }
}

/// Diagnosis Provider
final diagnosisProvider =
    StateNotifierProvider<DiagnosisNotifier, DiagnosisState>((ref) {
  return DiagnosisNotifier(ApiService());
});

/// Selected Child Diagnosis Provider (family provider)
final diagnosisByChildProvider =
    StateNotifierProvider.family<DiagnosisNotifier, DiagnosisState, String>(
        (ref, childId) {
  final notifier = DiagnosisNotifier(ApiService());
  notifier.fetchDiagnosisHistory(childId);
  return notifier;
});
