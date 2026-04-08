import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

/// Dashboard Stats State
class DashboardStatsState {
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final String? error;

  const DashboardStatsState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  DashboardStatsState copyWith({
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
  }) {
    return DashboardStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Dashboard Stats Notifier
class DashboardStatsNotifier extends StateNotifier<DashboardStatsState> {
  final ApiService _apiService;

  DashboardStatsNotifier(this._apiService) : super(const DashboardStatsState());

  /// Fetch dashboard statistics
  Future<void> fetchDashboardStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.getDashboardStats();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final statsData = data['data'];
          state = state.copyWith(stats: statsData, isLoading: false);
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal mengambil statistik dashboard',
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          error: 'Gagal mengambil statistik dashboard',
          isLoading: false,
        );
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
    state = const DashboardStatsState();
  }
}

/// Dashboard Stats Provider
final dashboardStatsProvider =
    StateNotifierProvider<DashboardStatsNotifier, DashboardStatsState>((ref) {
  return DashboardStatsNotifier(ApiService());
});
