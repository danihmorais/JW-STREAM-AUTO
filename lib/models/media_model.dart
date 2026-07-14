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
      // No fallback text here: this is the data layer and has no
      // BuildContext to localize with. Widgets decide what to show
      // for an empty title via AppLocalizations.
      title: json['title'] ?? '',
      url: parsedUrl,
      artworkUrl: parsedArtwork,
    );
  }
}