import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../services/download_service.dart';
import '../services/playlist_service.dart';
import 'add_to_playlist_sheet.dart';

class SongTile extends StatelessWidget {
  final MediaItemModel item;
  final String? playlistId;
  final VoidCallback? onPlaylistUpdate;
  final DownloadService _downloadService = DownloadService();
  final PlaylistService _playlistService = PlaylistService();

  SongTile({
    Key? key, 
    required this.item,
    this.playlistId,
    this.onPlaylistUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.title),
      subtitle: Text(item.category ?? 'Sem categoria'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadService.downloadItem(item),
          ),
          if (playlistId != null)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () async {
                await _playlistService.removeFromPlaylist(playlistId!, item.id);
                if (onPlaylistUpdate != null) {
                  onPlaylistUpdate!();
                }
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.playlist_add),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddToPlaylistSheet(item: item),
                );
              },
            ),
        ],
      ),
      onTap: () {
      },
    );
  }
}