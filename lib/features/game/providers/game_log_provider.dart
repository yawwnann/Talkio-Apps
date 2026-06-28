import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/game_log_model.dart';
import '../../../core/models/api_response_model.dart';
import '../../../core/services/api_service.dart';

/// Game Log State
class GameLogState {
  final List<GameLogModel> gameLogs;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  const GameLogState({
    this.gameLogs = const [],
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  GameLogState copyWith({
    List<GameLogModel>? gameLogs,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return GameLogState(
      gameLogs: gameLogs ?? this.gameLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Game Log Notifier
class GameLogNotifier extends StateNotifier<GameLogState> {
  final ApiService _apiService;

  GameLogNotifier(this._apiService) : super(const GameLogState());

  /// Get game history for a child
  Future<void> fetchGameHistory(String childId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getGameHistory(childId);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final gameLogs = ApiResponse.listFromJson<GameLogModel>(
            data,
            (json) => GameLogModel.fromJson(json),
          );

          state = state.copyWith(
            gameLogs: gameLogs,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal memuat riwayat permainan',
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

  /// Log a game result
  Future<bool> logGame({
    required String childId,
    required int gameScore,
    required int duration,
    required String gameType,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final response = await _apiService.logGame(
        childId: childId,
        gameScore: gameScore,
        duration: duration,
        gameType: gameType,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final newLog = GameLogModel.fromJson(data['data']);

          state = state.copyWith(
            gameLogs: [newLog, ...state.gameLogs],
            isSubmitting: false,
          );
          return true;
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal menyimpan hasil permainan',
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

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear state
  void clear() {
    state = const GameLogState();
  }
}

/// Game Log Provider
final gameLogProvider =
    StateNotifierProvider<GameLogNotifier, GameLogState>((ref) {
  return GameLogNotifier(ApiService());
});

/// Game Log by Child Provider (family provider)
final gameLogByChildProvider =
    StateNotifierProvider.family<GameLogNotifier, GameLogState, String>(
        (ref, childId) {
  final notifier = GameLogNotifier(ApiService());
  notifier.fetchGameHistory(childId);
  return notifier;
});
