import '../models/media_model.dart';
import '../models/playlist_model.dart';

class DownloadService {
  Future<void> downloadItem(MediaItemModel item) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> downloadPlaylist(Playlist playlist) async {
    for (var item in playlist.items) {
      await downloadItem(item);
    }
  }

  Future<void> downloadAll(List<MediaItemModel> items) async {
    for (var item in items) {
      await downloadItem(item);
    }
  }

  Future<bool> isDownloaded(String id) async {
    return false;
  }

  Future<String?> getFilePath(String id) async {
    return null;
  }
}