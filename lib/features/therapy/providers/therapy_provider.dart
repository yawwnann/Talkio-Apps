import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/therapy_session_model.dart';
import '../../../core/models/api_response_model.dart';
import '../../../core/services/api_service.dart';

/// Therapy State
class TherapyState {
  final List<TherapySessionModel> sessions;
  final bool isLoading;
  final String? error;
  final bool isBooking;
  final TherapySessionModel? lastBookedSession;
  final String? paymentUrl;

  const TherapyState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
    this.isBooking = false,
    this.lastBookedSession,
    this.paymentUrl,
  });

  TherapyState copyWith({
    List<TherapySessionModel>? sessions,
    bool? isLoading,
    String? error,
    bool? isBooking,
    TherapySessionModel? lastBookedSession,
    String? paymentUrl,
  }) {
    return TherapyState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isBooking: isBooking ?? this.isBooking,
      lastBookedSession: lastBookedSession ?? this.lastBookedSession,
      paymentUrl: paymentUrl ?? this.paymentUrl,
    );
  }
}

/// Therapy Notifier
class TherapyNotifier extends StateNotifier<TherapyState> {
  final ApiService _apiService;

  TherapyNotifier(this._apiService) : super(const TherapyState());

  /// Get therapy history
  Future<void> fetchTherapyHistory() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getTherapyHistory();

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final sessions = ApiResponse.listFromJson<TherapySessionModel>(
            data,
            (json) => TherapySessionModel.fromJson(json),
          );

          state = state.copyWith(
            sessions: sessions,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal memuat riwayat terapi',
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

  /// Book therapy session
  Future<bool> bookTherapy({
    required String childId,
    String? therapistId,
    required String schedule,
    required String therapyType,
  }) async {
    state = state.copyWith(isBooking: true, error: null);

    try {
      final response = await _apiService.bookTherapy(
        childId: childId,
        therapistId: therapistId,
        schedule: schedule,
        therapyType: therapyType,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final sessionData = data['data'];

          TherapySessionModel? session;
          String? paymentUrl;

          if (sessionData is Map<String, dynamic>) {
            // Backend returns: { session: {...}, paymentUrl: "...", amount: ... }
            if (sessionData['session'] != null) {
              session = TherapySessionModel.fromJson(sessionData['session']);
            }
            paymentUrl = sessionData['paymentUrl'] ?? sessionData['payment_url'];
          }

          state = state.copyWith(
            lastBookedSession: session,
            paymentUrl: paymentUrl,
            isBooking: false,
          );

          // Refresh history
          await fetchTherapyHistory();

          return true;
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal booking terapi',
            isBooking: false,
          );
          return false;
        }
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isBooking: false,
      );
      return false;
    }
  }

  /// Clear payment URL
  void clearPaymentUrl() {
    state = state.copyWith(paymentUrl: null);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear state
  void clear() {
    state = const TherapyState();
  }
}

/// Therapy Provider
final therapyProvider =
    StateNotifierProvider<TherapyNotifier, TherapyState>((ref) {
  return TherapyNotifier(ApiService());
});
