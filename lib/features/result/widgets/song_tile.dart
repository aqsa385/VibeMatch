import 'package:flutter/material.dart';

/// Hardcoded song for now. Replaced by the real Song model later.
class PlaceholderSong {
  const PlaceholderSong({
    required this.title,
    required this.genre,
    required this.duration,
    required this.colors,
  });
  final String title;
  final String genre;
  final String duration;
  final List<Color> colors;
}

class SongTile extends StatelessWidget {
  const SongTile({super.key, required this.song, required this.onPlay});
  final PlaceholderSong song;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: song.colors,
              ),
            ),
            child: const Icon(Icons.music_note_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${song.genre}  ·  ${song.duration}',
                    style: textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            iconSize: 38,
            onPressed: onPlay,
            icon: const Icon(Icons.play_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}