class MediaItemModel {
  final String title;
  final String url;
  final String artworkUrl;

  MediaItemModel({
    required this.title,
    required this.url,
    required this.artworkUrl,
  });

  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    String parsedUrl = '';
    String parsedArtwork = '';

    if (json['file'] != null && json['file']['url'] != null) {
      parsedUrl = json['file']['url'];
    }

    if (json['trackImage'] != null && json['trackImage']['url'] != null) {
      parsedArtwork = json['trackImage']['url'];
    } else if (json['images'] != null && json['images']['pss'] != null && json['images']['pss']['sm'] != null) {
      parsedArtwork = json['images']['pss']['sm'];
    }

    return MediaItemModel(
      title: json['title'] ?? 'Música sem título',
      url: parsedUrl,
      artworkUrl: parsedArtwork,
    );
  }
}