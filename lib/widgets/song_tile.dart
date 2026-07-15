import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/media_model.dart';
import '../services/audio_service.dart';
import '../services/download_service.dart';
import '../services/playlist_service.dart';
import '../screens/now_playing_screen.dart';
import 'add_to_playlist_sheet.dart';
import 'song_category.dart';

class SongTile extends StatefulWidget {
  final MediaItemModel item;
  final AudioService audioService;
  final DownloadService downloadService;
  // The other songs this tile lives alongside (its category or playlist),
  // so tapping one sets up proper next/previous instead of a 1-song queue.
  final List<MediaItemModel> queue;
  final int index;
  final String? playlistId;
  final VoidCallback? onPlaylistUpdate;

  const SongTile({
    Key? key,
    required this.item,
    required this.audioService,
    required this.downloadService,
    required this.queue,
    required this.index,
    this.playlistId,
    this.onPlaylistUpdate,
  }) : super(key: key);

  @override
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  late Future<DownloadStatus> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = widget.downloadService.status(widget.item);
  }

  Future<void> _refreshStatus() async {
    final future = widget.downloadService.status(widget.item);
    setState(() => _statusFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(widget.item.title),
      subtitle: widget.item.category != null
          ? Text(SongCategory.label(l10n, widget.item.category))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<DownloadStatus>(
            future: _statusFuture,
            builder: (context, snapshot) {
              final status = snapshot.data ?? DownloadStatus.notDownloaded;

              if (status == DownloadStatus.updateAvailable) {
                // The circular-arrows "update available" button the user
                // asked for: only shown once the song is downloaded AND
                // JW has published a newer file (different checksum/date).
                return IconButton(
                  icon: Icon(Icons.autorenew, color: Theme.of(context).colorScheme.primary),
                  tooltip: l10n.updateAvailableTooltip,
                  onPressed: () async {
                    await widget.downloadService.downloadItem(widget.item, force: true);
                    await _refreshStatus();
                  },
                );
              }

              return IconButton(
                icon: Icon(
                  status == DownloadStatus.upToDate
                      ? Icons.download_done
                      : Icons.download,
                ),
                onPressed: status == DownloadStatus.upToDate
                    ? null
                    : () async {
                        await widget.downloadService.downloadItem(widget.item);
                        await _refreshStatus();
                      },
              );
            },
          ),
          if (widget.playlistId != null)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () async {
                await PlaylistService().removeFromPlaylist(widget.playlistId!, widget.item.id);
                widget.onPlaylistUpdate?.call();
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.playlist_add),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddToPlaylistSheet(item: widget.item),
                );
              },
            ),
        ],
      ),
      onTap: () async {
        await widget.audioService.playQueue(
          widget.queue,
          widget.index,
          widget.downloadService,
        );
        if (!context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NowPlayingScreen(audioService: widget.audioService),
          ),
        );
      },
    );
  }
}
