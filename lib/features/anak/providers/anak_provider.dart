import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/anak_model.dart';
import '../../../core/services/api_service.dart';

/// Anak State
class AnakState {
  final List<AnakModel> anakList;
  final AnakModel? selectedAnak;
  final bool isLoading;
  final String? error;

  const AnakState({
    this.anakList = const [],
    this.selectedAnak,
    this.isLoading = false,
    this.error,
  });

  AnakState copyWith({
    List<AnakModel>? anakList,
    AnakModel? selectedAnak,
    bool? isLoading,
    String? error,
  }) {
    return AnakState(
      anakList: anakList ?? this.anakList,
      selectedAnak: selectedAnak ?? this.selectedAnak,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Anak Provider
class AnakNotifier extends StateNotifier<AnakState> {
  final ApiService _apiService;

  AnakNotifier(this._apiService) : super(const AnakState());

  /// Get all anak by parent ID (now calls GET /api/children)
  Future<void> getAnakList(String parentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getChildren();

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final anakListData = data['data'];
          List<AnakModel> anakList = [];
          
          if (anakListData is List) {
            anakList = anakListData
                .whereType<Map<String, dynamic>>()
                .map((item) => AnakModel.fromJson(item))
                .toList();
          }

          state = state.copyWith(anakList: anakList, isLoading: false);
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal memuat data anak',
            isLoading: false,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Get all anak (for therapist) - now calls GET /api/therapist/patients
  Future<void> fetchAllAnak() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getTherapistPatients();

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final anakListData = data['data'];
          List<AnakModel> anakList = [];
          
          if (anakListData is List) {
            anakList = anakListData
                .whereType<Map<String, dynamic>>()
                .map((item) => AnakModel.fromJson(item))
                .toList();
          }

          state = state.copyWith(anakList: anakList, isLoading: false);
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal memuat data anak',
            isLoading: false,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Add new anak
  Future<bool> addAnak(AnakModel anak) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.createChild(
        name: anak.name,
        dateOfBirth: anak.dateOfBirth.toIso8601String().split('T')[0],
        gender: anak.gender,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final newAnakData = data['data'] as Map<String, dynamic>;
          final newAnak = AnakModel.fromJson(newAnakData);

          final updatedList = [...state.anakList, newAnak];

          state = state.copyWith(anakList: updatedList, isLoading: false);

          return true;
        } else {
          final message = data['message'] ?? 'Gagal menambahkan data anak';
          state = state.copyWith(error: message, isLoading: false);
          return false;
        }
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Update anak (not supported by backend - mock only)
  Future<bool> updateAnak(AnakModel anak) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.updateAnak(anak.id, anak.toJson());

      if (response.statusCode == 200) {
        final data = response.data;
        // Backend doesn't support update, so this will likely fail
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final updatedAnakData = data['data'] as Map<String, dynamic>;
          final updatedAnak = AnakModel.fromJson(updatedAnakData);

          final updatedList = state.anakList.map((item) {
            return item.id == anak.id ? updatedAnak : item;
          }).toList();

          state = state.copyWith(
            anakList: updatedList,
            selectedAnak: state.selectedAnak?.id == anak.id
                ? updatedAnak
                : state.selectedAnak,
            isLoading: false,
          );

          return true;
        }
      }
      
      final message = response.data is Map<String, dynamic> 
          ? response.data['message'] ?? 'Update tidak didukung oleh backend'
          : 'Update tidak didukung oleh backend';
      state = state.copyWith(error: message, isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Delete anak (not supported by backend - mock only)
  Future<bool> deleteAnak(String anakId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.deleteAnak(anakId);

      if (response.statusCode == 200) {
        final data = response.data;
        // Backend doesn't support delete, so this will likely fail
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final updatedList = state.anakList
              .where((item) => item.id != anakId)
              .toList();

          state = state.copyWith(
            anakList: updatedList,
            selectedAnak: state.selectedAnak?.id == anakId
                ? null
                : state.selectedAnak,
            isLoading: false,
          );

          return true;
        }
      }

      final message = response.data is Map<String, dynamic>
          ? response.data['message'] ?? 'Delete tidak didukung oleh backend'
          : 'Delete tidak didukung oleh backend';
      state = state.copyWith(error: message, isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Select anak
  void selectAnak(AnakModel anak) {
    state = state.copyWith(selectedAnak: anak);
  }

  /// Clear selected anak
  void clearSelectedAnak() {
    state = state.copyWith(selectedAnak: null);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Anak Provider Instance
final anakProvider = StateNotifierProvider<AnakNotifier, AnakState>((ref) {
  return AnakNotifier(ApiService());
});

/// Selected Anak Provider
final selectedAnakProvider = Provider<AnakModel?>((ref) {
  return ref.watch(anakProvider).selectedAnak;
});
