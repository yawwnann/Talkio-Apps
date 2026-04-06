import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/jadwal_model.dart';
import '../../../core/services/api_service.dart';

/// Jadwal State
class JadwalState {
  final List<JadwalModel> jadwalList;
  final bool isLoading;
  final String? error;

  const JadwalState({
    this.jadwalList = const [],
    this.isLoading = false,
    this.error,
  });

  JadwalState copyWith({
    List<JadwalModel>? jadwalList,
    bool? isLoading,
    String? error,
  }) {
    return JadwalState(
      jadwalList: jadwalList ?? this.jadwalList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Jadwal Notifier
class JadwalNotifier extends StateNotifier<JadwalState> {
  final ApiService _apiService;

  JadwalNotifier(this._apiService) : super(const JadwalState());

  /// Fetch jadwal for therapist (GET /api/therapist/patients)
  Future<void> fetchJadwal() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.getTherapistPatients();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final jadwalData = data['data'];
          List<JadwalModel> jadwalList = [];

          if (jadwalData is List) {
            jadwalList = jadwalData
                .whereType<Map<String, dynamic>>()
                .map((item) => JadwalModel.fromJson(item))
                .toList();
          }

          state = state.copyWith(jadwalList: jadwalList, isLoading: false);
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal mengambil jadwal',
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          error: 'Gagal mengambil jadwal',
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
    state = const JadwalState();
  }
}

/// Jadwal Provider
final jadwalProvider = StateNotifierProvider<JadwalNotifier, JadwalState>((ref) {
  return JadwalNotifier(ApiService());
});
