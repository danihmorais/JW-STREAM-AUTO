import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/media_model.dart';
import 'download_service.dart';

/// Wraps just_audio with playlist support so the car head unit
/// (Android Auto / CarPlay "Now Playing") gets real next/previous
/// controls instead of a single isolated track.
class AudioService {
  final AudioPlayer player = AudioPlayer();
  List<MediaItemModel> _queue = [];

  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<int?> get currentIndexStream => player.currentIndexStream;
  Stream<bool> get playingStream => player.playingStream;

  MediaItemModel? get currentSong =>
      (player.currentIndex != null && player.currentIndex! < _queue.length)
          ? _queue[player.currentIndex!]
          : null;

  void initialize() {}

  /// Builds a playlist so seekToNext/seekToPrevious work, and picks
  /// local (downloaded) files over network streaming when available.
  Future<void> playQueue(
    List<MediaItemModel> songs,
    int startIndex,
    DownloadService downloadService,
  ) async {
    _queue = songs;
    final sources = <AudioSource>[];

    for (final song in songs) {
      final filename = song.url.split('/').last;
      final isLocal = await downloadService.isDownloaded(filename);
      final path = isLocal ? await downloadService.getFilePath(filename) : song.url;

      sources.add(
        AudioSource.uri(
          isLocal ? Uri.file(path) : Uri.parse(path),
          tag: MediaItem(
            id: path,
            album: 'JW Stream Auto',
            title: song.title,
            artUri: song.artworkUrl.isNotEmpty ? Uri.parse(song.artworkUrl) : null,
          ),
        ),
      );
    }

    try {
      await player.setAudioSources(
        sources,
        initialIndex: startIndex,
      );
      await player.play();
    } catch (_) {}
  }

  void playPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  Future<void> next() async {
    if (player.hasNext) await player.seekToNext();
  }

  Future<void> previous() async {
    if (player.hasPrevious) await player.seekToPrevious();
  }

  void seek(Duration position) => player.seek(position);

  void pause() => player.pause();

  void stop() => player.stop();

  void dispose() => player.dispose();
}