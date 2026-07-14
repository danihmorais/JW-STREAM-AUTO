import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_model.dart';
import '../models/playlist_model.dart';

/// Persists user-created playlists as JSON in SharedPreferences. Kept
/// independent of any screen so the playlists list, the "add to playlist"
/// sheet, and the playlist detail screen all share the same source of
/// truth instead of duplicating read/write logic.
class PlaylistService {
  static const _prefsKey = 'user_playlists';

  Future<List<PlaylistModel>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? const [];
    return raw
        .map((s) => PlaylistModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      playlists.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  Future<PlaylistModel> createPlaylist(String name) async {
    final playlists = await loadPlaylists();
    final playlist = PlaylistModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
    playlists.add(playlist);
    await _save(playlists);
    return playlist;
  }

  Future<void> deletePlaylist(String id) async {
    final playlists = await loadPlaylists();
    playlists.removeWhere((p) => p.id == id);
    await _save(playlists);
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final playlists = await loadPlaylists();
    final playlist = playlists.where((p) => p.id == id).firstOrNull;
    if (playlist == null) return;
    playlist.name = newName;
    await _save(playlists);
  }

  /// Returns true if the song was added, false if it was already there.
  Future<bool> addSong(String playlistId, MediaItemModel song) async {
    final playlists = await loadPlaylists();
    final playlist = playlists.where((p) => p.id == playlistId).firstOrNull;
    if (playlist == null || playlist.containsSong(song)) return false;
    playlist.songs.add(song);
    await _save(playlists);
    return true;
  }

  Future<void> removeSong(String playlistId, MediaItemModel song) async {
    final playlists = await loadPlaylists();
    final playlist = playlists.where((p) => p.id == playlistId).firstOrNull;
    if (playlist == null) return;
    playlist.songs.removeWhere((s) => s.url == song.url);
    await _save(playlists);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}