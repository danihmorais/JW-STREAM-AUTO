import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_model.dart';
import '../models/playlist_model.dart';

/// Whether a song is not downloaded at all, downloaded and current, or
/// downloaded but out of date compared to what's on JW's servers.
enum DownloadStatus { notDownloaded, upToDate, updateAvailable }

class DownloadService extends ChangeNotifier {
  static const String _manifestKey = 'download_manifest';
  final Dio _dio = Dio();

  // id -> progress (0.0-1.0) while actually downloading, or -1 while
  // queued/waiting its turn but not yet started. Absent = not active.
  // SongTile listens to this (via the same DownloadService instance
  // threaded down from HomeScreen) to show a spinner instead of the
  // download icon.
  final Map<String, double> _activeProgress = {};

  bool isActive(String id) => _activeProgress.containsKey(id);

  /// Null means "queued, no known progress yet" (indeterminate spinner).
  double? progressOf(String id) {
    final value = _activeProgress[id];
    if (value == null || value < 0) return null;
    return value;
  }

  /// id -> {path, checksum, modifiedDatetime}
  Future<Map<String, dynamic>> _readManifest() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_manifestKey);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _writeManifest(Map<String, dynamic> manifest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_manifestKey, jsonEncode(manifest));
  }

  Future<Directory> _songsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/songs');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Downloads (or re-downloads) a song and records the version metadata
  /// (checksum/modifiedDatetime) it was downloaded at, so we can later tell
  /// whether JW has published a newer file for the same track.
  ///
  /// By default, skips the network call if the file is already downloaded
  /// and matches the version in [item]. Pass [force] to always re-download
  /// (used by the update button).
  Future<void> downloadItem(MediaItemModel item, {bool force = false}) async {
    final manifest = await _readManifest();

    if (!force) {
      final status = _statusFromManifest(manifest, item);
      if (status == DownloadStatus.upToDate) {
        _activeProgress.remove(item.id);
        notifyListeners();
        return;
      }
    }

    // Mark as queued/indeterminate immediately so the UI can show a
    // spinner even before the first progress event arrives.
    _activeProgress.putIfAbsent(item.id, () => -1);
    notifyListeners();

    try {
      final dir = await _songsDir();
      final extension = item.url.split('.').last.split('?').first;
      final filePath = '${dir.path}/${item.id}.$extension';

      await _dio.download(
        item.url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            _activeProgress[item.id] = received / total;
            notifyListeners();
          }
        },
      );

      manifest[item.id] = {
        'path': filePath,
        'checksum': item.checksum,
        'modifiedDatetime': item.modifiedDatetime,
      };
      await _writeManifest(manifest);
    } finally {
      _activeProgress.remove(item.id);
      notifyListeners();
    }
  }

  Future<void> downloadPlaylist(Playlist playlist) async {
    // Mark every item as queued right away so the whole batch shows a
    // spinner immediately, not just the one currently downloading.
    for (var item in playlist.items) {
      _activeProgress.putIfAbsent(item.id, () => -1);
    }
    notifyListeners();
    for (var item in playlist.items) {
      await downloadItem(item);
    }
  }

  Future<void> downloadAll(List<MediaItemModel> items) async {
    for (var item in items) {
      _activeProgress.putIfAbsent(item.id, () => -1);
    }
    notifyListeners();
    for (var item in items) {
      await downloadItem(item);
    }
  }

  Future<bool> isDownloaded(String id) async {
    final manifest = await _readManifest();
    final entry = manifest[id];
    if (entry == null) return false;
    return File(entry['path'] as String).exists();
  }

  Future<String?> getFilePath(String id) async {
    final manifest = await _readManifest();
    final entry = manifest[id];
    if (entry == null) return null;
    final path = entry['path'] as String;
    return await File(path).exists() ? path : null;
  }

  /// Compares the downloaded copy's recorded checksum/modifiedDatetime
  /// against the freshly-fetched [item] to see whether JW has published a
  /// newer version of the file since it was downloaded.
  Future<DownloadStatus> status(MediaItemModel item) async {
    final manifest = await _readManifest();
    return _statusFromManifest(manifest, item);
  }

  DownloadStatus _statusFromManifest(
    Map<String, dynamic> manifest,
    MediaItemModel item,
  ) {
    final entry = manifest[item.id];
    if (entry == null) return DownloadStatus.notDownloaded;

    final storedChecksum = entry['checksum'] as String?;
    final storedModified = entry['modifiedDatetime'] as String?;

    // Prefer checksum (exact content match); fall back to the publish
    // date if the server didn't return one.
    final changed = (item.checksum != null && storedChecksum != null)
        ? item.checksum != storedChecksum
        : (item.modifiedDatetime != null &&
            storedModified != null &&
            item.modifiedDatetime != storedModified);

    return changed ? DownloadStatus.updateAvailable : DownloadStatus.upToDate;
  }
}
