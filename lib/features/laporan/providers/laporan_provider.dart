import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/laporan_model.dart';
import '../../../core/services/api_service.dart';

/// Laporan State
class LaporanState {
  final List<LaporanModel> laporanList;
  final bool isLoading;
  final String? error;

  const LaporanState({
    this.laporanList = const [],
    this.isLoading = false,
    this.error,
  });

  LaporanState copyWith({
    List<LaporanModel>? laporanList,
    bool? isLoading,
    String? error,
  }) {
    return LaporanState(
      laporanList: laporanList ?? this.laporanList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Laporan Notifier
class LaporanNotifier extends StateNotifier<LaporanState> {
  final ApiService _apiService;

  LaporanNotifier(this._apiService) : super(const LaporanState());

  /// Fetch laporan for therapist (GET /api/therapist/reports)
  Future<void> fetchLaporan() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.getReportHistory();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final laporanData = data['data'];
          List<LaporanModel> laporanList = [];

          if (laporanData is List) {
            laporanList = laporanData
                .whereType<Map<String, dynamic>>()
                .map((item) => LaporanModel.fromJson(item))
                .toList();
          }

          state = state.copyWith(laporanList: laporanList, isLoading: false);
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal mengambil laporan',
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          error: 'Gagal mengambil laporan',
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
    state = const LaporanState();
  }
}

/// Laporan Provider
final laporanProvider = StateNotifierProvider<LaporanNotifier, LaporanState>((ref) {
  return LaporanNotifier(ApiService());
});
