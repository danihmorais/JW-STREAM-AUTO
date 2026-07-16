import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/media_model.dart';
import '../models/playlist_model.dart';
import '../services/playlist_service.dart';

class AddToPlaylistSheet extends StatefulWidget {
  final MediaItemModel item;
  // Lets the caller (HomeScreen) know a playlist was created or changed
  // so it can refresh its own list — otherwise the "Playlists" tab keeps
  // showing stale data until the next full reload.
  final VoidCallback? onPlaylistsChanged;

  const AddToPlaylistSheet({
    Key? key,
    required this.item,
    this.onPlaylistsChanged,
  }) : super(key: key);

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<AddToPlaylistSheet> {
  final PlaylistService _playlistService = PlaylistService();
  List<Playlist> _playlists = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final playlists = await _playlistService.getPlaylists();
    if (!mounted) return;
    setState(() {
      _playlists = playlists;
    });
  }

  Future<void> _createAndAdd() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    await _playlistService.createPlaylist(name);
    final playlists = await _playlistService.getPlaylists();
    final created = playlists.last;
    await _playlistService.addToPlaylist(created.id, widget.item);
    _controller.clear();

    // Notify the parent right away and refresh this sheet's own list,
    // but stay open: the user asked for the sheet to stop closing itself
    // the moment a playlist is created, so they can keep adding the song
    // to more playlists or create another one without reopening it.
    widget.onPlaylistsChanged?.call();
    await _loadPlaylists();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(AppLocalizations.of(context).addedToPlaylist(created.name)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.addToPlaylist,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: l10n.playlistNameHint),
                  onSubmitted: (_) => _createAndAdd(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: l10n.create,
                onPressed: _createAndAdd,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // `shrinkWrap: true` already makes this ListView size itself to
          // its content, so it doesn't need (and can't use) `Expanded`
          // here — the parent Column is `mainAxisSize.min`, which gives
          // an unbounded height and crashes any flex child.
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: _playlists.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      l10n.noPlaylistsYet,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = _playlists[index];
                      final alreadyIn =
                          playlist.items.any((i) => i.id == widget.item.id);
                      return ListTile(
                        title: Text(playlist.name),
                        trailing: alreadyIn ? const Icon(Icons.check) : null,
                        onTap: alreadyIn
                            ? null
                            : () async {
                                await _playlistService.addToPlaylist(
                                    playlist.id, widget.item);
                                widget.onPlaylistsChanged?.call();
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
