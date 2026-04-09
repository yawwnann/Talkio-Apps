import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

/// Parent Payment State
class ParentPaymentState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> paymentList;

  const ParentPaymentState({
    this.isLoading = false,
    this.error,
    this.paymentList = const [],
  });

  ParentPaymentState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? paymentList,
  }) {
    return ParentPaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      paymentList: paymentList ?? this.paymentList,
    );
  }
}

/// Parent Payment Notifier
class ParentPaymentNotifier extends StateNotifier<ParentPaymentState> {
  final ApiService _apiService;

  ParentPaymentNotifier(this._apiService) : super(const ParentPaymentState());

  /// Fetch payments for parent's children
  Future<void> fetchPayments({String? status, String? childId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final queryParameters = <String, dynamic>{};
      if (status != null) queryParameters['status'] = status;
      if (childId != null) queryParameters['childId'] = childId;

      final response = await _apiService.dio.get(
        '/parent/payments',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final paymentData = data['data'] as List<dynamic>;
          state = state.copyWith(
            paymentList: paymentData.cast<Map<String, dynamic>>(),
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal memuat pembayaran',
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
    state = const ParentPaymentState();
  }
}

/// Provider
final parentPaymentProvider = StateNotifierProvider<ParentPaymentNotifier, ParentPaymentState>((ref) {
  return ParentPaymentNotifier(ApiService());
});
