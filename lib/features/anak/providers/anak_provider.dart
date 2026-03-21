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
  AnakNotifier(ApiService apiService) : super(const AnakState());

  /// Get all anak by parent ID
  Future<void> getAnakList(String parentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final mockData = [
        {
          'id': '1',
          'parent_id': parentId,
          'name': 'Ahmad Rizki',
          'birth_date': '2020-05-15T00:00:00.000Z',
          'gender': 'L',
          'medical_history': 'Tidak ada riwayat penyakit khusus',
          'current_condition': 'Belum bisa mengucapkan kata dengan jelas',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'parent_id': parentId,
          'name': 'Siti Aisyah',
          'birth_date': '2019-08-20T00:00:00.000Z',
          'gender': 'P',
          'medical_history': 'Lahir prematur',
          'current_condition': 'Kesulitan dalam komunikasi verbal',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      final anakList = mockData
          .map((data) => AnakModel.fromJson(data))
          .toList();

      state = state.copyWith(anakList: anakList, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Add new anak
  Future<bool> addAnak(AnakModel anak) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));

      final newAnak = anak.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedList = [...state.anakList, newAnak];

      state = state.copyWith(anakList: updatedList, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Update anak
  Future<bool> updateAnak(AnakModel anak) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));

      final updatedAnak = anak.copyWith(updatedAt: DateTime.now());

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
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Delete anak
  Future<bool> deleteAnak(String anakId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));

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
