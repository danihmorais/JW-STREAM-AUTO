import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<String?> downloadTrack(String url, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }

      await _dio.download(url, filePath);
      return filePath;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isDownloaded(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    return await file.exists();
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