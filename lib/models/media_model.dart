class MediaItemModel {
  final String id;
  final String title;
  final String url;
  final String? category;
  final String? coverUrl;

  MediaItemModel({
    required this.id,
    required this.title,
    required this.url,
    this.category,
    this.coverUrl,
  });

  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    return MediaItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      category: json['category'] as String?,
      coverUrl: json['coverUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'category': category,
      'coverUrl': coverUrl,
    };
  }
}