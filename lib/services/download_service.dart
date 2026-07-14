import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media_model.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<String?> downloadTrack(String url, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    if (await file.exists()) {
      return filePath;
    }

    // Download to a temp file first. If the app is killed or the
    // connection drops mid-download, we're left with a `.part` file
    // instead of a truncated file at the real path — so a later
    // isDownloaded() check can't mistake a partial download for a
    // complete one.
    final tempPath = '$filePath.part';
    final tempFile = File(tempPath);
    try {
      await _dio.download(url, tempPath);
      if (!await tempFile.exists() || await tempFile.length() == 0) {
        await tempFile.delete().catchError((_) => tempFile);
        return null;
      }
      await tempFile.rename(filePath);
      return filePath;
    } catch (_) {
      if (await tempFile.exists()) {
        await tempFile.delete().catchError((_) => tempFile);
      }
      return null;
    }
  }

  Future<bool> isDownloaded(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    return await file.exists();
  }

  Future<String> getFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  /// Downloads every track sequentially (one at a time, so we don't blow
  /// past the CDN's per-client connection limits on a large playlist).
  /// [onProgress] fires after each track — success or failure — so a
  /// progress dialog can advance even if one file can't be fetched.
  /// Returns the number of tracks that failed to download.
  Future<int> downloadAll(
    List<MediaItemModel> songs, {
    void Function(int completed, int total)? onProgress,
  }) async {
    var failures = 0;
    for (var i = 0; i < songs.length; i++) {
      final filename = songs[i].url.split('/').last;
      if (!await isDownloaded(filename)) {
        final path = await downloadTrack(songs[i].url, filename);
        if (path == null) failures++;
      }
      onProgress?.call(i + 1, songs.length);
    }
    return failures;
  }

  Future<void> deleteTrack(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}