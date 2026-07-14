import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../models/playlist_model.dart';
import '../services/api_service.dart';
import '../services/playlist_service.dart';
import '../services/download_service.dart';
import '../widgets/song_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final PlaylistService _playlistService = PlaylistService();
  final DownloadService _downloadService = DownloadService();

  List<MediaItemModel> _allItems = [];
  List<Playlist> _playlists = [];
  Map<String, List<MediaItemModel>> _groupedItems = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    _allItems = await _apiService.fetchMedia();
    _playlists = await _playlistService.getPlaylists();

    _groupedItems = {};
    for (var item in _allItems) {
      final category = item.category ?? 'Outros';
      if (!_groupedItems.containsKey(category)) {
        _groupedItems[category] = [];
      }
      _groupedItems[category]!.add(item);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('JW Stream Auto'),
          actions: [
            IconButton(
              icon: const Icon(Icons.download_for_offline),
              onPressed: () => _downloadService.downloadAll(_allItems),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Cânticos'),
              Tab(text: 'Playlists'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGroupedList(),
            _buildPlaylists(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _loadData,
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _buildGroupedList() {
    return ListView.builder(
      itemCount: _groupedItems.length,
      itemBuilder: (context, index) {
        final category = _groupedItems.keys.elementAt(index);
        final items = _groupedItems[category]!;

        return ExpansionTile(
          title: Text(category),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _downloadService.downloadAll(items),
              ),
              const Icon(Icons.expand_more),
            ],
          ),
          children: items.map((item) => SongTile(item: item)).toList(),
        );
      },
    );
  }

  Widget _buildPlaylists() {
    return ListView.builder(
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final playlist = _playlists[index];
        return ExpansionTile(
          title: Text(playlist.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _downloadService.downloadPlaylist(playlist),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await _playlistService.deletePlaylist(playlist.id);
                  _loadData();
                },
              ),
              const Icon(Icons.expand_more),
            ],
          ),
          children: playlist.items.map((item) => SongTile(
            item: item,
            playlistId: playlist.id,
            onPlaylistUpdate: _loadData,
          )).toList(),
        );
      },
    );
  }
}