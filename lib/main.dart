import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'services/api_service.dart';
import 'services/audio_service.dart';
import 'services/download_service.dart';
import 'models/media_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.jwstreamauto.channel.audio',
    androidNotificationChannelName: 'Reprodução de Áudio',
    androidNotificationOngoing: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JW Stream Auto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AudioService _audioService = AudioService();
  final DownloadService _downloadService = DownloadService();

  List<MediaItemModel> _songs = [];
  String _currentLang = 'T';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
    _loadSongs();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    setState(() {
      _isLoading = true;
    });
    final songs = await _apiService.fetchSongs(_currentLang, 'sjjm');
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _currentLang = _currentLang == 'T' ? 'E' : 'T';
    });
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                return SongListItem(
                  song: song,
                  audioService: _audioService,
                  downloadService: _downloadService,
                );
              },
            ),
    );
  }
}

class SongListItem extends StatefulWidget {
  final MediaItemModel song;
  final AudioService audioService;
  final DownloadService downloadService;

  const SongListItem({
    super.key,
    required this.song,
    required this.audioService,
    required this.downloadService,
  });

  @override
  State<SongListItem> createState() => _SongListItemState();
}

class _SongListItemState extends State<SongListItem> {
  bool _isDownloaded = false;
  bool _isDownloading = false;
  String _localPath = '';

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final filename = widget.song.url.split('/').last;
    final isDownloaded = await widget.downloadService.isDownloaded(filename);
    if (mounted) {
      setState(() {
        _isDownloaded = isDownloaded;
      });
    }
  }

  Future<void> _handleDownload() async {
    if (_isDownloaded) {
      final filename = widget.song.url.split('/').last;
      await widget.downloadService.deleteTrack(filename);
      setState(() {
        _isDownloaded = false;
        _localPath = '';
      });
    } else {
      setState(() {
        _isDownloading = true;
      });
      final filename = widget.song.url.split('/').last;
      final path = await widget.downloadService.downloadTrack(widget.song.url, filename);
      if (path != null && mounted) {
        setState(() {
          _isDownloaded = true;
          _localPath = path;
          _isDownloading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
        }
      }
    }
  }

  Future<void> _handlePlay() async {
    String path = widget.song.url;
    bool isLocal = false;

    if (_isDownloaded) {
      final filename = widget.song.url.split('/').last;
      path = await widget.downloadService.getFilePath(filename);
      isLocal = true;
    }

    await widget.audioService.play(
      path,
      widget.song.title,
      'JW Stream Auto',
      widget.song.artworkUrl,
      isLocal: isLocal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.song.artworkUrl.isNotEmpty
          ? Image.network(widget.song.artworkUrl, width: 50, height: 50, fit: BoxFit.cover)
          : const Icon(Icons.music_note, size: 50),
      title: Text(widget.song.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(_isDownloaded ? Icons.download_done : Icons.download),
            onPressed: _isDownloading ? null : _handleDownload,
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _handlePlay,
          ),
        ],
      ),
    );
  }
}