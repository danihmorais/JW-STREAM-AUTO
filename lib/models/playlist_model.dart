import 'media_model.dart';

class Playlist {
  final String id;
  final String name;
  final List<MediaItemModel> items;

  Playlist({
    required this.id,
    required this.name,
    required this.items,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MediaItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}