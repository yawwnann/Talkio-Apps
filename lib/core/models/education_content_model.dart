/// Education Content Model
/// Model untuk konten edukasi (artikel dan video)
class EducationContentModel {
  final String id;
  final String title;
  final String? description;
  final String content; // PDF path untuk article, YouTube URL untuk video
  final String type; // 'ARTICLE' atau 'VIDEO'
  final String? thumbnail;
  final String? embedUrl;
  final String? videoId;
  final bool isActive;
  final int order;
  final Map<String, dynamic>? author;
  final DateTime createdAt;
  final DateTime updatedAt;

  EducationContentModel({
    required this.id,
    required this.title,
    this.description,
    required this.content,
    required this.type,
    this.thumbnail,
    this.embedUrl,
    this.videoId,
    this.isActive = true,
    this.order = 0,
    this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EducationContentModel.fromJson(Map<String, dynamic> json) {
    return EducationContentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      content: json['content'] ?? '',
      type: json['type'] ?? 'ARTICLE',
      thumbnail: json['thumbnail'],
      embedUrl: json['embedUrl'],
      videoId: json['videoId'],
      isActive: json['isActive'] ?? true,
      order: json['order'] ?? 0,
      author: json['author'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'type': type,
      'thumbnail': thumbnail,
      'embedUrl': embedUrl,
      'videoId': videoId,
      'isActive': isActive,
      'order': order,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isArticle => type == 'ARTICLE';
  bool get isVideo => type == 'VIDEO';
}
