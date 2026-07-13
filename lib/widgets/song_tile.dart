import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../services/audio_service.dart';
import '../services/download_service.dart';

class SongTile extends StatefulWidget {
  final MediaItemModel song;
  final int index;
  final List<MediaItemModel> queue;
  final AudioService audioService;
  final DownloadService downloadService;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    required this.index,
    required this.queue,
    required this.audioService,
    required this.downloadService,
    required this.isPlaying,
  });

  @override
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  bool _isDownloaded = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final filename = widget.song.url.split('/').last;
    final isDownloaded = await widget.downloadService.isDownloaded(filename);
    if (mounted) setState(() => _isDownloaded = isDownloaded);
  }

  Future<void> _handleDownload() async {
    final filename = widget.song.url.split('/').last;
    if (_isDownloaded) {
      await widget.downloadService.deleteTrack(filename);
      if (mounted) setState(() => _isDownloaded = false);
    } else {
      setState(() => _isDownloading = true);
      final path = await widget.downloadService.downloadTrack(widget.song.url, filename);
      if (mounted) {
        setState(() {
          _isDownloaded = path != null;
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.song.artworkUrl.isNotEmpty
            ? Image.network(
                widget.song.artworkUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: theme.colorScheme.primaryContainer,
                  child: const Icon(Icons.music_note),
                ),
              )
            : Container(
                width: 48,
                height: 48,
                color: theme.colorScheme.primaryContainer,
                child: const Icon(Icons.music_note),
              ),
      ),
      title: Text(
        widget.song.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: widget.isPlaying
            ? TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)
            : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_isDownloaded ? Icons.download_done : Icons.download_outlined),
            onPressed: _isDownloading ? null : _handleDownload,
          ),
        ],
      ),
      onTap: () => widget.audioService.playQueue(
        widget.queue,
        widget.index,
        widget.downloadService,
      ),
    );
  }
}
