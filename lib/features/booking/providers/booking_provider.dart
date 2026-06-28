import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

/// Booking State
class BookingState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> therapists;
  final Map<String, dynamic>? availability;
  final Map<String, dynamic>? bookingResult;
  final String? lastBookedTime; // Track recently booked time for UI sync

  const BookingState({
    this.isLoading = false,
    this.error,
    this.therapists = const [],
    this.availability,
    this.bookingResult,
    this.lastBookedTime,
  });

  BookingState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? therapists,
    Map<String, dynamic>? availability,
    Map<String, dynamic>? bookingResult,
    String? lastBookedTime,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      therapists: therapists ?? this.therapists,
      availability: availability ?? this.availability,
      bookingResult: bookingResult ?? this.bookingResult,
      lastBookedTime: lastBookedTime ?? this.lastBookedTime,
    );
  }
}

/// Booking Notifier
class BookingNotifier extends StateNotifier<BookingState> {
  final ApiService _apiService;

  BookingNotifier(this._apiService) : super(const BookingState());

  /// Fetch list of therapists
  Future<void> fetchTherapists() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.dio.get('/therapist/list');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final therapistData = data['data'] as List<dynamic>;
          state = state.copyWith(
            therapists: therapistData.whereType<Map<String, dynamic>>().toList(),
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal memuat therapist',
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

  /// Fetch therapist availability for a specific date
  Future<void> fetchAvailability(String therapistId, String date) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.dio.get(
        '/therapist/availability',
        queryParameters: {
          'therapistId': therapistId,
          'date': date,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          state = state.copyWith(
            availability: data['data'],
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal memuat ketersediaan',
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

  /// Book a therapy session
  Future<Map<String, dynamic>?> bookSession({
    required String childId,
    required String therapistId,
    required String schedule,
    required String therapyType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.dio.post(
        '/therapy/booking',
        data: {
          'childId': childId,
          'therapistId': therapistId,
          'schedule': schedule,
          'therapyType': therapyType,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          state = state.copyWith(
            bookingResult: data['data'],
            isLoading: false,
          );
          return data['data'];
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal melakukan booking',
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
    return null;
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear booking result
  void clearBookingResult() {
    state = state.copyWith(bookingResult: null);
  }

  /// Set last booked time for UI synchronization
  void setLastBookedTime(String? time) {
    state = state.copyWith(lastBookedTime: time);
  }

  /// Clear state
  void clear() {
    state = const BookingState();
  }
}

/// Provider
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ApiService());
});
