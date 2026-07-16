import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';
import '../models/media_model.dart';

class PlaylistService {
  static const String _storageKey = 'user_playlists';

  Future<List<Playlist>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Playlist.fromJson(e)).toList();
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(playlists.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> createPlaylist(String name) async {
    final playlists = await getPlaylists();
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      items: [],
    );
    playlists.add(newPlaylist);
    await savePlaylists(playlists);
  }

  Future<void> addToPlaylist(String playlistId, MediaItemModel item) async {
    final playlists = await getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      if (!playlists[index].items.any((i) => i.id == item.id)) {
        playlists[index].items.add(item);
        await savePlaylists(playlists);
      }
    }
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    final playlists = await getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      playlists[index] = playlists[index].copyWith(name: newName);
      await savePlaylists(playlists);
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String itemId) async {
    final playlists = await getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      playlists[index].items.removeWhere((i) => i.id == itemId);
      await savePlaylists(playlists);
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    final playlists = await getPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    await savePlaylists(playlists);
  }
}
