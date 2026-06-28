import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class AdminPaymentState {
  final List<Map<String, dynamic>> transactions;
  final bool isLoading;
  final String? error;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final Map<String, int> summary;

  const AdminPaymentState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.totalPages = 0,
    this.summary = const {'success': 0, 'pending': 0, 'failed': 0},
  });

  AdminPaymentState copyWith({
    List<Map<String, dynamic>>? transactions,
    bool? isLoading,
    String? error,
    int? total,
    int? page,
    int? limit,
    int? totalPages,
    Map<String, int>? summary,
  }) {
    return AdminPaymentState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
      summary: summary ?? this.summary,
    );
  }
}

class AdminPaymentNotifier extends StateNotifier<AdminPaymentState> {
  final ApiService _apiService;

  AdminPaymentNotifier(this._apiService) : super(const AdminPaymentState());

  Future<void> fetchPayments({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getAdminPayments(
        page: page,
        limit: limit,
        status: status,
        search: search,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final responseData = data['data'] as Map<String, dynamic>;
          final transactions = (responseData['transactions'] as List<dynamic>)
              .map((t) => t as Map<String, dynamic>)
              .toList();
          final pagination = responseData['pagination'] as Map<String, dynamic>;
          final summary = responseData['summary'] as Map<String, dynamic>;

          state = state.copyWith(
            transactions: transactions,
            total: pagination['total'] ?? 0,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            totalPages: pagination['totalPages'] ?? 0,
            summary: {
              'success': summary['success'] ?? 0,
              'pending': summary['pending'] ?? 0,
              'failed': summary['failed'] ?? 0,
            },
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          error: 'Gagal memuat data pembayaran',
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
}

final adminPaymentProvider =
    StateNotifierProvider<AdminPaymentNotifier, AdminPaymentState>((ref) {
  return AdminPaymentNotifier(ApiService());
});
