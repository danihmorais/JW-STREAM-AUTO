import 'media_model.dart';

/// A user-created playlist. Songs are stored by value (title/url/artwork)
/// rather than by reference into the catalog, so a playlist keeps working
/// even if it mixes songs from different categories/languages.
class PlaylistModel {
  final String id;
  String name;
  final List<MediaItemModel> songs;

  PlaylistModel({
    required this.id,
    required this.name,
    List<MediaItemModel>? songs,
  }) : songs = songs ?? [];

  bool containsSong(MediaItemModel song) =>
      songs.any((s) => s.url == song.url);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songs': songs
            .map((s) => {
                  'title': s.title,
                  'url': s.url,
                  'artworkUrl': s.artworkUrl,
                })
            .toList(),
      };

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final rawSongs = (json['songs'] as List?) ?? const [];
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      songs: rawSongs
          .map((s) => MediaItemModel(
                title: (s as Map)['title'] ?? '',
                url: s['url'] ?? '',
                artworkUrl: s['artworkUrl'] ?? '',
              ))
          .toList(),
    );
  }
}