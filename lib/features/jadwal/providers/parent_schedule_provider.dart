import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

/// Parent Schedule State
class ParentScheduleState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> scheduleList;

  const ParentScheduleState({
    this.isLoading = false,
    this.error,
    this.scheduleList = const [],
  });

  ParentScheduleState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? scheduleList,
  }) {
    return ParentScheduleState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      scheduleList: scheduleList ?? this.scheduleList,
    );
  }
}

/// Parent Schedule Notifier
class ParentScheduleNotifier extends StateNotifier<ParentScheduleState> {
  final ApiService _apiService;

  ParentScheduleNotifier(this._apiService) : super(const ParentScheduleState());

  /// Fetch schedule for parent's children
  Future<void> fetchSchedule({String? status, String? childId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final queryParameters = <String, dynamic>{};
      if (status != null) queryParameters['status'] = status;
      if (childId != null) queryParameters['childId'] = childId;

      final response = await _apiService.dio.get(
        '/parent/schedule',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final scheduleData = data['data'] as List<dynamic>;
          state = state.copyWith(
            scheduleList: scheduleData.cast<Map<String, dynamic>>(),
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal memuat jadwal',
            isLoading: false,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear state
  void clear() {
    state = const ParentScheduleState();
  }
}

/// Provider
final parentScheduleProvider = StateNotifierProvider<ParentScheduleNotifier, ParentScheduleState>((ref) {
  return ParentScheduleNotifier(ApiService());
});
