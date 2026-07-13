import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/download_service.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AudioService _audioService = AudioService();
  final DownloadService _downloadService = DownloadService();
  final TextEditingController _searchController = TextEditingController();

  List<MediaItemModel> _songs = [];
  List<MediaItemModel> _filteredSongs = [];
  String _currentLang = 'T';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
    _loadSongs();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);
    final songs = await _apiService.fetchSongs(_currentLang, 'sjjm');
    setState(() {
      _songs = songs;
      _filteredSongs = songs;
      _isLoading = false;
    });
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredSongs = query.isEmpty
          ? _songs
          : _songs.where((s) => s.title.toLowerCase().contains(query)).toList();
    });
  }

  void _toggleLanguage() {
    setState(() => _currentLang = _currentLang == 'T' ? 'E' : 'T');
    _loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JW Stream Auto'),
        actions: [
          IconButton(
            icon: Text(
              _currentLang == 'T' ? 'PT' : 'EN',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onPressed: _toggleLanguage,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar música...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSongs.isEmpty
                    ? const Center(child: Text('Nenhuma música encontrada'))
                    : StreamBuilder<int?>(
                        stream: _audioService.currentIndexStream,
                        builder: (context, _) {
                          final currentSong = _audioService.currentSong;
                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: _filteredSongs.length,
                            itemBuilder: (context, index) {
                              final song = _filteredSongs[index];
                              return SongTile(
                                song: song,
                                index: index,
                                queue: _filteredSongs,
                                audioService: _audioService,
                                downloadService: _downloadService,
                                isPlaying: currentSong?.url == song.url,
                              );
                            },
                          );
                        },
                      ),
          ),
          MiniPlayer(audioService: _audioService),
        ],
      ),
    );
  }
}
