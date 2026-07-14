import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../models/playlist_model.dart';
import '../services/playlist_service.dart';

class AddToPlaylistSheet extends StatefulWidget {
  final MediaItemModel item;

  const AddToPlaylistSheet({Key? key, required this.item}) : super(key: key);

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
    if (_controller.text.isNotEmpty) {
      await _playlistService.createPlaylist(_controller.text);
      await _loadPlaylists();
      if (_playlists.isNotEmpty) {
        await _playlistService.addToPlaylist(_playlists.last.id, widget.item);
      }
      _controller.clear();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Text('Adicionar à Playlist', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Nova Playlist'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _createAndAdd,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _playlists.length,
              itemBuilder: (context, index) {
                final playlist = _playlists[index];
                return ListTile(
                  title: Text(playlist.name),
                  onTap: () async {
                    await _playlistService.addToPlaylist(playlist.id, widget.item);
                    if (!mounted) return;
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