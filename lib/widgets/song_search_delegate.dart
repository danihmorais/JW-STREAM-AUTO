import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../services/audio_service.dart';
import '../services/download_service.dart';
import 'song_tile.dart';

class SongSearchDelegate extends SearchDelegate<MediaItemModel?> {
  final List<MediaItemModel> allItems;
  final AudioService audioService;
  final DownloadService downloadService;
  final VoidCallback onPlaylistUpdate;

  SongSearchDelegate({
    required this.allItems,
    required this.audioService,
    required this.downloadService,
    required this.onPlaylistUpdate,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = allItems.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('Nenhum resultado encontrado'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return SongTile(
          item: results[index],
          audioService: audioService,
          downloadService: downloadService,
          queue: results,
          index: index,
          onPlaylistUpdate: onPlaylistUpdate,
        );
      },
    );
  }
}