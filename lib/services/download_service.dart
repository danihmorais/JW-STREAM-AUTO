import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

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