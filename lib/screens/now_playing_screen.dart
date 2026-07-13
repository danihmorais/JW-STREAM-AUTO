import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_service.dart';

class NowPlayingScreen extends StatelessWidget {
  final AudioService audioService;

  const NowPlayingScreen({super.key, required this.audioService});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<int?>(
          stream: audioService.currentIndexStream,
          builder: (context, _) {
            final song = audioService.currentSong;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: song != null && song.artworkUrl.isNotEmpty
                        ? Image.network(
                            song.artworkUrl,
                            width: 260,
                            height: 260,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderArt(theme),
                          )
                        : _placeholderArt(theme),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    song?.title ?? 'Nenhuma música selecionada',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  StreamBuilder<Duration?>(
                    stream: audioService.durationStream,
                    builder: (context, durationSnap) {
                      final duration = durationSnap.data ?? Duration.zero;
                      return StreamBuilder<Duration>(
                        stream: audioService.positionStream,
                        builder: (context, positionSnap) {
                          var position = positionSnap.data ?? Duration.zero;
                          if (position > duration) position = duration;
                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 6,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                ),
                                child: Slider(
                                  min: 0,
                                  max: duration.inMilliseconds > 0
                                      ? duration.inMilliseconds.toDouble()
                                      : 1,
                                  value: position.inMilliseconds
                                      .clamp(0, duration.inMilliseconds > 0 ? duration.inMilliseconds : 1)
                                      .toDouble(),
                                  onChanged: (value) => audioService
                                      .seek(Duration(milliseconds: value.toInt())),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDuration(position)),
                                    Text(_formatDuration(duration)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 48,
                        icon: const Icon(Icons.skip_previous),
                        onPressed: audioService.previous,
                      ),
                      StreamBuilder<PlayerState>(
                        stream: audioService.playerStateStream,
                        builder: (context, snapshot) {
                          final playing = snapshot.data?.playing ?? false;
                          final processingState = snapshot.data?.processingState;
                          final isLoading = processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering;

                          return SizedBox(
                            width: 84,
                            height: 84,
                            child: isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  )
                                : IconButton.filled(
                                    iconSize: 48,
                                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                                    onPressed: audioService.playPause,
                                  ),
                          );
                        },
                      ),
                      IconButton(
                        iconSize: 48,
                        icon: const Icon(Icons.skip_next),
                        onPressed: audioService.next,
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholderArt(ThemeData theme) {
    return Container(
      width: 260,
      height: 260,
      color: theme.colorScheme.primaryContainer,
      child: Icon(
        Icons.music_note,
        size: 96,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}
