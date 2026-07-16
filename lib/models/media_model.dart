class MediaItemModel {
  final String id;
  final String title;
  final String url;
  final String? category;
  final String? coverUrl;
  // Used to detect when a previously-downloaded file has been replaced by a
  // newer version on JW's servers (e.g. re-recorded track, fixed audio).
  final String? checksum;
  final String? modifiedDatetime;

  MediaItemModel({
    required this.id,
    required this.title,
    required this.url,
    this.category,
    this.coverUrl,
    this.checksum,
    this.modifiedDatetime,
  });

  /// Parses a single track entry as returned by JW's GETPUBMEDIALINKS API.
  /// That endpoint nests the playable file (url/checksum/modifiedDatetime)
  /// under a `file` object and never sends `id`, `coverUrl` or `category` —
  /// those are things we attach ourselves.
  factory MediaItemModel.fromApiJson(Map<String, dynamic> json,
      {String? category}) {
    final file = json['file'] as Map<String, dynamic>? ?? const {};
    final url = file['url'] as String? ?? '';
    final track = json['track'];
    return MediaItemModel(
      id: '${category ?? 'song'}-${track ?? url}',
      title: json['title'] as String? ?? '',
      url: url,
      category: category,
      checksum: file['checksum'] as String?,
      modifiedDatetime: file['modifiedDatetime'] as String?,
    );
  }

  /// Round-trips through the app's own local storage (playlists cache),
  /// which always uses this flat shape — never the raw API shape above.
  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    return MediaItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      category: json['category'] as String?,
      coverUrl: json['coverUrl'] as String?,
      checksum: json['checksum'] as String?,
      modifiedDatetime: json['modifiedDatetime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'category': category,
      'coverUrl': coverUrl,
      'checksum': checksum,
      'modifiedDatetime': modifiedDatetime,
    };
  }
}
