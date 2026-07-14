import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/media_model.dart';
import '../services/playlist_service.dart';

/// Shows a bottom sheet listing the user's playlists plus a "new
/// playlist" entry, and adds [song] to whichever one is picked. Shared
/// between the song list and the playlist detail screen so both add
/// songs the same way.
Future<void> showAddToPlaylistSheet(
  BuildContext context,
  PlaylistService playlistService,
  MediaItemModel song,
) async {
  final l10n = AppLocalizations.of(context);
  final playlists = await playlistService.loadPlaylists();
  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  l10n.addToPlaylist,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final playlist in playlists)
                      ListTile(
                        leading: const Icon(Icons.playlist_play),
                        title: Text(playlist.name),
                        onTap: () async {
                          final added =
                              await playlistService.addSong(playlist.id, song);
                          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  added
                                      ? l10n.addedToPlaylist(playlist.name)
                                      : playlist.name,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(l10n.newPlaylist),
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        final created = await _promptNewPlaylistName(context, l10n);
                        if (created == null || created.trim().isEmpty) return;
                        final playlist =
                            await playlistService.createPlaylist(created.trim());
                        await playlistService.addSong(playlist.id, song);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.addedToPlaylist(playlist.name))),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<String?> _promptNewPlaylistName(
  BuildContext context,
  AppLocalizations l10n,
) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.newPlaylist),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: l10n.playlistNameHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: Text(l10n.create),
        ),
      ],
    ),
  );
}