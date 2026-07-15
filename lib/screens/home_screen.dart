import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/media_model.dart';
import '../models/playlist_model.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/playlist_service.dart';
import '../services/download_service.dart';
import '../services/theme_service.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_category.dart';

class HomeScreen extends StatefulWidget {
  final ThemeService themeService;

  const HomeScreen({Key? key, required this.themeService}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final PlaylistService _playlistService = PlaylistService();
  final DownloadService _downloadService = DownloadService();
  final AudioService _audioService = AudioService();

  List<MediaItemModel> _allItems = [];
  List<Playlist> _playlists = [];
  Map<String, List<MediaItemModel>> _groupedItems = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
    _loadData();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // The JW media API only speaks its own "langwritten" codes (e.g.
      // 'T' for Portuguese, 'E' for English) — not standard locale codes.
      final deviceLanguage = ui.PlatformDispatcher.instance.locale.languageCode;
      final langCode = deviceLanguage == 'pt' ? 'T' : 'E';

      _allItems = await _apiService.fetchAllSongs(langCode);
      _playlists = await _playlistService.getPlaylists();

      _groupedItems = {};
      for (var item in _allItems) {
        final category = item.category ?? 'Outros';
        _groupedItems.putIfAbsent(category, () => []).add(item);
      }
    } on ApiServiceException catch (e) {
      _error = e.message;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.loadError, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadData, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('JW Stream Auto'),
          actions: [
            ValueListenableBuilder<ThemeMode>(
              valueListenable: widget.themeService.themeMode,
              builder: (context, mode, _) => IconButton(
                icon: Icon(mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                tooltip: l10n.themeToggleTooltip,
                onPressed: widget.themeService.toggle,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download_for_offline),
              tooltip: l10n.downloadAll,
              onPressed: () => _downloadService.downloadAll(_allItems),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.categoriesTab),
              Tab(text: l10n.playlistsTab),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildGroupedList(),
                  _buildPlaylists(),
                ],
              ),
            ),
            MiniPlayer(audioService: _audioService),
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
    final l10n = AppLocalizations.of(context);

    return ListView.builder(
      itemCount: _groupedItems.length,
      itemBuilder: (context, index) {
        final category = _groupedItems.keys.elementAt(index);
        final items = _groupedItems[category]!;

        return ExpansionTile(
          title: Text(SongCategory.label(l10n, category)),
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
          children: items
              .asMap()
              .entries
              .map((e) => SongTile(
                    item: e.value,
                    audioService: _audioService,
                    downloadService: _downloadService,
                    queue: items,
                    index: e.key,
                  ))
              .toList(),
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
          children: playlist.items
              .asMap()
              .entries
              .map((e) => SongTile(
                    item: e.value,
                    audioService: _audioService,
                    downloadService: _downloadService,
                    queue: playlist.items,
                    index: e.key,
                    playlistId: playlist.id,
                    onPlaylistUpdate: _loadData,
                  ))
              .toList(),
        );
      },
    );
  }
}
