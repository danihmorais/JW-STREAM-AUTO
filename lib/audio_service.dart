import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  void initialize() {}

  Future<void> play(String path, String title, String album, String artworkUrl, {required bool isLocal}) async {
    try {
      final source = AudioSource.uri(
        isLocal ? Uri.file(path) : Uri.parse(path),
        tag: MediaItem(
          id: path,
          album: album,
          title: title,
          artUri: Uri.parse(artworkUrl),
        ),
      );
      await _player.setAudioSource(source);
      _player.play();
    } catch (_) {}
  }

  void pause() {
    _player.pause();
  }

  void stop() {
    _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}