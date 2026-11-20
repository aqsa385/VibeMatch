import 'package:flutter/material.dart';

/// All moods the user can pick. valence = sad(0) to happy(1),
/// energy = calm(0) to intense(1). Songs will use the same two numbers.
enum Mood {
  happy(label: 'Happy', tagline: 'bright, joyful', icon: Icons.wb_sunny_rounded, color: Color(0xFFFFB300), background: Color(0xFFFFF3D6), valence: 0.90, energy: 0.70),
  romantic(label: 'Romantic', tagline: 'warm, tender', icon: Icons.favorite_rounded, color: Color(0xFFEC407A), background: Color(0xFFFCE4EC), valence: 0.70, energy: 0.35),
  chill(label: 'Chill', tagline: 'soft, relaxed', icon: Icons.waves_rounded, color: Color(0xFF42A5F5), background: Color(0xFFE3F2FD), valence: 0.60, energy: 0.20),
  sad(label: 'Sad', tagline: 'quiet, blue', icon: Icons.cloud_rounded, color: Color(0xFF7E57C2), background: Color(0xFFEDE7F6), valence: 0.15, energy: 0.20),
  energetic(label: 'Energetic', tagline: 'lively, punchy', icon: Icons.bolt_rounded, color: Color(0xFF43A047), background: Color(0xFFE8F5E9), valence: 0.80, energy: 0.95),
  dreamy(label: 'Dreamy', tagline: 'floaty, gentle', icon: Icons.air_rounded, color: Color(0xFFFB8C00), background: Color(0xFFFFE9D6), valence: 0.55, energy: 0.25),
  focused(label: 'Focused', tagline: 'calm, steady', icon: Icons.center_focus_strong_rounded, color: Color(0xFF00897B), background: Color(0xFFE0F2F1), valence: 0.50, energy: 0.45),
  nostalgic(label: 'Nostalgic', tagline: 'warm, wistful', icon: Icons.history_rounded, color: Color(0xFF8D6E63), background: Color(0xFFEFEBE9), valence: 0.40, energy: 0.35),
  mysterious(label: 'Mysterious', tagline: 'dark, deep', icon: Icons.nights_stay_rounded, color: Color(0xFF3949AB), background: Color(0xFFE8EAF6), valence: 0.30, energy: 0.50),
  confident(label: 'Confident', tagline: 'bold, strong', icon: Icons.local_fire_department_rounded, color: Color(0xFFC62828), background: Color(0xFFFFEBEE), valence: 0.80, energy: 0.80);

  const Mood({
    required this.label,
    required this.tagline,
    required this.icon,
    required this.color,
    required this.background,
    required this.valence,
    required this.energy,
  });

  final String label;
  final String tagline;
  final IconData icon;
  final Color color;
  final Color background;
  final double valence;
  final double energy;
}