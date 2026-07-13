import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_service.dart';
import '../screens/now_playing_screen.dart';

class MiniPlayer extends StatelessWidget {
  final AudioService audioService;

  const MiniPlayer({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<int?>(
      stream: audioService.currentIndexStream,
      builder: (context, _) {
        final song = audioService.currentSong;
        if (song == null) return const SizedBox.shrink();

        return SafeArea(
          top: false,
          child: Material(
            color: theme.colorScheme.surfaceContainerHighest,
            elevation: 8,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NowPlayingScreen(audioService: audioService),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: song.artworkUrl.isNotEmpty
                          ? Image.network(
                              song.artworkUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 44,
                                height: 44,
                                color: theme.colorScheme.primaryContainer,
                                child: const Icon(Icons.music_note),
                              ),
                            )
                          : Container(
                              width: 44,
                              height: 44,
                              color: theme.colorScheme.primaryContainer,
                              child: const Icon(Icons.music_note),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: audioService.previous,
                    ),
                    StreamBuilder<PlayerState>(
                      stream: audioService.playerStateStream,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        return IconButton(
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                          onPressed: audioService.playPause,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: audioService.next,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
