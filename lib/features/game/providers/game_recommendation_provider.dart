import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/game_recommendation_model.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/services/api_service.dart';

class GameRecommendationState {
  final GameRecommendationResponse? recommendations;
  final bool isLoading;
  final String? error;

  const GameRecommendationState({
    this.recommendations,
    this.isLoading = false,
    this.error,
  });

  GameRecommendationState copyWith({
    GameRecommendationResponse? recommendations,
    bool? isLoading,
    String? error,
  }) {
    return GameRecommendationState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GameRecommendationNotifier extends StateNotifier<GameRecommendationState> {
  final ApiService _apiService;

  GameRecommendationNotifier(this._apiService)
      : super(const GameRecommendationState());

  Future<void> fetchRecommendations(String childId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getGameRecommendations(childId);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> &&
            (data['status'] == 'success' || data['success'] == true)) {
          final recJson = data['data'];
          if (recJson is Map<String, dynamic>) {
            final rec = GameRecommendationResponse.fromJson(recJson);
            state = state.copyWith(recommendations: rec, isLoading: false);
            return;
          }
        }

        state = state.copyWith(
          error: (data is Map<String, dynamic>)
              ? (data['message'] ?? 'Gagal memuat rekomendasi game')
              : 'Gagal memuat rekomendasi game',
          isLoading: false,
        );
        return;
      }

      state = state.copyWith(
        error: 'Gagal memuat rekomendasi game',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clear() {
    state = const GameRecommendationState();
  }
}

final gameRecommendationByChildProvider =
    StateNotifierProvider.family<GameRecommendationNotifier, GameRecommendationState, String>(
        (ref, childId) {
  final dio = ref.watch(dioProvider);
  final uploadDio = ref.watch(uploadDioProvider);
  final notifier = GameRecommendationNotifier(
    ApiService.withDio(dio: dio, uploadDio: uploadDio),
  );

  notifier.fetchRecommendations(childId);
  return notifier;
});
