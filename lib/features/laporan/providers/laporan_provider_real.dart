import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/laporan_model.dart';
import '../../../core/services/storage_service.dart';

/// Laporan Provider - REAL API ONLY (NO MOCK)
/// Provider untuk laporan yang langsung menembak API tanpa mock

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

class LaporanNotifier extends StateNotifier<LaporanState> {
  final Dio _dio = Dio();

  LaporanNotifier() : super(const LaporanState()) {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get auth token from storage
        final token = StorageService.getString(AppConstants.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔑 Using token: ${token.substring(0, 20)}...');
        } else {
          print('⚠️ WARNING: No auth token found!');
        }
        print('🚀 [REAL API REQUEST] ${options.method} ${options.uri}');
        print('   Headers: ${options.headers}');
        if (options.data != null) {
          print('   Data: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ [REAL API RESPONSE] ${response.statusCode}');
        print('   URL: ${response.requestOptions.uri}');
        print('   Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ [REAL API ERROR]');
        print('   URL: ${error.requestOptions.uri}');
        print('   Status: ${error.response?.statusCode}');
        print('   Message: ${error.message}');
        print('   Response: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }

  /// Fetch laporan - REAL API CALL
  Future<void> fetchLaporan() async {
    print('========================================');
    print('🔄 Fetching laporan from REAL API...');
    print('   Base URL: ${AppConstants.baseUrl}');
    print('   Endpoint: /therapist/reports');
    print('========================================');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.get('/therapist/reports');

      if (response.statusCode == 200) {
        final data = response.data;
        print('📦 Response data type: ${data.runtimeType}');
        print('📦 Response data: $data');

        if (data is Map<String, dynamic>) {
          if (data['status'] == 'success') {
            final laporanData = data['data'];
            List<LaporanModel> laporanList = [];

            if (laporanData is List) {
              print('✅ Found ${laporanData.length} items in response');
              laporanList = laporanData
                  .whereType<Map<String, dynamic>>()
                  .map((item) {
                    print('📄 Parsing item: $item');
                    return LaporanModel.fromJson(item);
                  })
                  .toList();
            }

            print('✅ Loaded ${laporanList.length} laporan from API');
            state = state.copyWith(laporanList: laporanList, isLoading: false);
          } else {
            final errorMsg = data['message'] ?? 'Gagal mengambil laporan';
            print('❌ API returned error: $errorMsg');
            state = state.copyWith(
              error: errorMsg,
              isLoading: false,
            );
          }
        } else {
          print('❌ Unexpected response format: ${data.runtimeType}');
          state = state.copyWith(
            error: 'Invalid response format',
            isLoading: false,
          );
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        state = state.copyWith(
          error: 'Server error: ${response.statusCode}',
          isLoading: false,
        );
      }
    } catch (e) {
      print('❌ Exception fetching laporan: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Create laporan - REAL API CALL
  /// status: "DRAFT" or "SENT"
  Future<bool> createLaporan({
    required String childId,
    required String title,
    required String progressNotes,
    String? sessionDate,
    double? speechClarity,
    double? vocabulary,
    double? socialInteraction,
    String? barriers,
    List<String>? parentExercises,
    String status = "DRAFT",
  }) async {
    print('========================================');
    print('🚀 Creating laporan via REAL API...');
    print('   Patient: $childId');
    print('   Title: $title');
    print('   Status: $status');
    print('========================================');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = <String, dynamic>{
        'childId': childId,
        'title': title,
        'progressNotes': progressNotes,
        'status': status,
      };

      if (sessionDate != null) data['sessionDate'] = sessionDate;
      if (speechClarity != null) data['speechClarity'] = speechClarity;
      if (vocabulary != null) data['vocabulary'] = vocabulary;
      if (socialInteraction != null) data['socialInteraction'] = socialInteraction;
      if (barriers != null) data['barriers'] = barriers;
      if (parentExercises != null) data['parentExercises'] = parentExercises;

      print('📤 Sending POST request...');
      print('   Payload: $data');

      final response = await _dio.post('/therapist/report', data: data);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Laporan created successfully with status: $status!');
        state = state.copyWith(isLoading: false);
        // Refresh laporan list
        await fetchLaporan();
        return true;
      } else {
        final errorMsg = response.data is Map
            ? response.data['message'] ?? 'Gagal menyimpan laporan'
            : 'Gagal menyimpan laporan';
        print('❌ Server returned error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Error creating laporan: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Publish/Send laporan - REAL API CALL
  Future<bool> publishLaporan({required String laporanId}) async {
    print('========================================');
    print('🚀 Publishing laporan via REAL API...');
    print('   Laporan ID: $laporanId');
    print('========================================');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = <String, dynamic>{
        'status': 'SENT',
      };

      print('📤 Sending PATCH request...');
      print('   URL: /therapist/report/$laporanId');
      print('   Payload: $data');

      final response = await _dio.patch('/therapist/report/$laporanId', data: data);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Laporan published successfully!');
        state = state.copyWith(isLoading: false);
        // Refresh laporan list
        await fetchLaporan();
        return true;
      } else {
        final errorMsg = response.data is Map
            ? response.data['message'] ?? 'Gagal mempublikasikan laporan'
            : 'Gagal mempublikasikan laporan';
        print('❌ Server returned error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Error publishing laporan: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Update laporan - REAL API CALL
  Future<bool> updateLaporan({
    required String laporanId,
    required String childId,
    required String title,
    required String progressNotes,
    String? sessionDate,
    double? speechClarity,
    double? vocabulary,
    double? socialInteraction,
    String? barriers,
    List<String>? parentExercises,
    String? status,
  }) async {
    print('========================================');
    print('🚀 Updating laporan via REAL API...');
    print('   Laporan ID: $laporanId');
    print('========================================');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = <String, dynamic>{
        'childId': childId,
        'title': title,
        'progressNotes': progressNotes,
      };

      if (sessionDate != null) data['sessionDate'] = sessionDate;
      if (speechClarity != null) data['speechClarity'] = speechClarity;
      if (vocabulary != null) data['vocabulary'] = vocabulary;
      if (socialInteraction != null) data['socialInteraction'] = socialInteraction;
      if (barriers != null) data['barriers'] = barriers;
      if (parentExercises != null) data['parentExercises'] = parentExercises;
      if (status != null) data['status'] = status;

      print('📤 Sending PATCH request...');
      print('   Payload: $data');

      final response = await _dio.patch('/therapist/report/$laporanId', data: data);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Laporan updated successfully!');
        state = state.copyWith(isLoading: false);
        await fetchLaporan();
        return true;
      } else {
        final errorMsg = response.data is Map
            ? response.data['message'] ?? 'Gagal memperbarui laporan'
            : 'Gagal memperbarui laporan';
        print('❌ Server returned error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Error updating laporan: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clear() {
    state = const LaporanState();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}

final laporanProvider = StateNotifierProvider<LaporanNotifier, LaporanState>((ref) {
  return LaporanNotifier();
});
