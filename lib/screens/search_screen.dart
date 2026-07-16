import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/media_model.dart';
import '../services/audio_service.dart';
import '../services/download_service.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';

/// Replaces the old `showSearch` / SongSearchDelegate flow.
///
/// `showSearch` pushes Flutter's built-in search route, which has its own
/// Scaffold — that's why the MiniPlayer (set as HomeScreen's
/// bottomNavigationBar) disappeared while searching. This screen is a
/// regular route with its own MiniPlayer, and it tells SongTile not to
/// jump to the Now Playing screen on tap (openNowPlayingOnTap: false) so
/// starting a song here just plays it in the mini player, as expected.
class SearchScreen extends StatefulWidget {
  final List<MediaItemModel> allItems;
  final AudioService audioService;
  final DownloadService downloadService;
  final VoidCallback onPlaylistUpdate;

  const SearchScreen({
    Key? key,
    required this.allItems,
    required this.audioService,
    required this.downloadService,
    required this.onPlaylistUpdate,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = _query.isEmpty
        ? const <MediaItemModel>[]
        : widget.allItems
            .where((item) =>
                item.title.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? const SizedBox.shrink()
          : results.isEmpty
              ? Center(child: Text(l10n.noSongsFound))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return SongTile(
                      key: ValueKey(item.id),
                      item: item,
                      audioService: widget.audioService,
                      downloadService: widget.downloadService,
                      queue: results,
                      index: index,
                      onPlaylistUpdate: widget.onPlaylistUpdate,
                      openNowPlayingOnTap: false,
                    );
                  },
                ),
      bottomNavigationBar: MiniPlayer(
        audioService: widget.audioService,
        onPlaylistsChanged: widget.onPlaylistUpdate,
      ),
    );
  }
}
