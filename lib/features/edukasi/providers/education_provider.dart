import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/education_content_model.dart';
import '../../../core/services/api_service.dart';

/// Education State
class EducationState {
  final List<EducationContentModel> contents;
  final List<EducationContentModel> articles;
  final List<EducationContentModel> videos;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  const EducationState({
    this.contents = const [],
    this.articles = const [],
    this.videos = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
  });

  EducationState copyWith({
    List<EducationContentModel>? contents,
    List<EducationContentModel>? articles,
    List<EducationContentModel>? videos,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
  }) {
    return EducationState(
      contents: contents ?? this.contents,
      articles: articles ?? this.articles,
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}

/// Education Notifier
class EducationNotifier extends StateNotifier<EducationState> {
  final ApiService _apiService;

  EducationNotifier(this._apiService) : super(const EducationState());

  /// Fetch all education content
  Future<void> fetchEducationContent({
    String? type,
    int page = 1,
    int limit = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getEducationContent(
        type: type,
        isActive: true,
        page: page,
        limit: limit,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final contentData = data['data'];
          final contentsList = contentData['contents'] as List?;

          List<EducationContentModel> contents = [];
          if (contentsList != null) {
            contents = contentsList
                .whereType<Map<String, dynamic>>()
                .map((item) => EducationContentModel.fromJson(item))
                .toList();
          }

          // Separate articles and videos
          final articles = contents.where((c) => c.isArticle).toList();
          final videos = contents.where((c) => c.isVideo).toList();

          state = state.copyWith(
            contents: contents,
            articles: articles,
            videos: videos,
            currentPage: page,
            totalPages: contentData['pagination']?['totalPages'] ?? 1,
            totalItems: contentData['pagination']?['total'] ?? 0,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            error: data['message'] ?? 'Gagal memuat konten edukasi',
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          error: 'Gagal memuat konten edukasi',
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

  /// Fetch articles only
  Future<void> fetchArticles({int page = 1, int limit = 10}) async {
    await fetchEducationContent(type: 'ARTICLE', page: page, limit: limit);
  }

  /// Fetch videos only
  Future<void> fetchVideos({int page = 1, int limit = 10}) async {
    await fetchEducationContent(type: 'VIDEO', page: page, limit: limit);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear state
  void clear() {
    state = const EducationState();
  }
}

/// Education Provider
final educationProvider = StateNotifierProvider<EducationNotifier, EducationState>((ref) {
  return EducationNotifier(ApiService());
});
