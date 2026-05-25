import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class AdminReportState {
  final List<Map<String, dynamic>> reports;
  final bool isLoading;
  final String? error;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final Map<String, int> summary;

  const AdminReportState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.totalPages = 0,
    this.summary = const {'sent': 0, 'draft': 0},
  });

  AdminReportState copyWith({
    List<Map<String, dynamic>>? reports,
    bool? isLoading,
    String? error,
    int? total,
    int? page,
    int? limit,
    int? totalPages,
    Map<String, int>? summary,
  }) {
    return AdminReportState(
      reports: reports ?? this.reports,
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

class AdminReportNotifier extends StateNotifier<AdminReportState> {
  final ApiService _apiService;

  AdminReportNotifier(this._apiService) : super(const AdminReportState());

  Future<void> fetchReports({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getAdminReports(
        page: page,
        limit: limit,
        status: status,
        search: search,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final responseData = data['data'] as Map<String, dynamic>;
          final reports = (responseData['reports'] as List<dynamic>)
              .map((r) => r as Map<String, dynamic>)
              .toList();
          final pagination = responseData['pagination'] as Map<String, dynamic>;
          final summary = responseData['summary'] as Map<String, dynamic>;

          state = state.copyWith(
            reports: reports,
            total: pagination['total'] ?? 0,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            totalPages: pagination['totalPages'] ?? 0,
            summary: {
              'sent': summary['sent'] ?? 0,
              'draft': summary['draft'] ?? 0,
            },
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          error: 'Gagal memuat data laporan',
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

final adminReportProvider =
    StateNotifierProvider<AdminReportNotifier, AdminReportState>((ref) {
  return AdminReportNotifier(ApiService());
});
