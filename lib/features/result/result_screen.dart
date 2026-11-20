import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/color_extractor.dart';
import '../../data/models/mood.dart';
import 'widgets/song_tile.dart';

class ResultArgs {
  const ResultArgs({
    this.mood,
    this.imagePath,
    this.colors = const [],
    this.valence,
    this.energy,
  });
  final Mood? mood;
  final String? imagePath;
  final List<ExtractedColor> colors;
  final double? valence; // from the photo, used later for the playlist
  final double? energy;
}

// Placeholder playlist. Real playlist generation comes later.
const _placeholderSongs = [
  PlaceholderSong(
    title: 'Ocean Breeze',
    genre: 'Chill Vibes',
    duration: '3:28',
    colors: [Color(0xFF64B5F6), Color(0xFF3949AB)],
  ),
  PlaceholderSong(
    title: 'Better Days',
    genre: 'Lo-fi Beats',
    duration: '4:12',
    colors: [Color(0xFFFFB74D), Color(0xFFD81B60)],
  ),
  PlaceholderSong(
    title: 'Slow Motion',
    genre: 'Indie Pop',
    duration: '4:03',
    colors: [Color(0xFF5C6BC0), Color(0xFF263238)],
  ),
  PlaceholderSong(
    title: 'Golden Hour',
    genre: 'Acoustic',
    duration: '3:50',
    colors: [Color(0xFFFFD54F), Color(0xFF4DB6AC)],
  ),
];

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, this.args});
  final ResultArgs? args;

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final path = args?.imagePath;
    final colors = args?.colors ?? const <ExtractedColor>[];
    final mood = args?.mood ?? Mood.chill;
    final fromPhoto = path != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Vibe Match'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  if (path != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(path),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text('Your Vibe',
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (colors.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('Colors extracted', style: textTheme.titleSmall),
                    const SizedBox(height: 10),
                    _PaletteRow(colors: colors),
                  ],
                  const SizedBox(height: 18),
                  _MoodChip(
                    mood: mood,
                    text: '${mood.label} : ${mood.tagline}',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 6),
                    child: Text(
                      fromPhoto ? 'Detected from your photo' : 'Mood you picked',
                      style: textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Playlist',
                            style: textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      TextButton.icon(
                        onPressed: () => _comingSoon(context, 'Saving'),
                        icon: const Icon(Icons.bookmark_border_rounded),
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                  for (final song in _placeholderSongs)
                    SongTile(
                      song: song,
                      onPlay: () => _comingSoon(context, 'Playback'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push('/select-mood'),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      child: const Text('Change mood'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _comingSoon(context, 'More songs'),
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      child: const Text('More songs'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({required this.colors});
  final List<ExtractedColor> colors;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const gap = 12.0;
      final n = colors.length;
      final size =
      ((constraints.maxWidth - gap * (n - 1)) / n).clamp(30.0, 56.0);
      return Row(
        children: [
          for (var i = 0; i < n; i++) ...[
            if (i > 0) const SizedBox(width: gap),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: colors[i].color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12, width: 1.5),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.mood, required this.text});
  final Mood mood;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: mood.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: mood.color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(mood.icon, color: mood.color, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}