import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/utils/color_extractor.dart';
import '../data/models/mood.dart';

class MoodResult {
  const MoodResult({
    required this.mood,
    required this.valence,
    required this.energy,
  });
  final Mood mood;
  final double valence; // 0 sad ... 1 happy
  final double energy; // 0 calm ... 1 intense
}

/// Summary numbers worked out from the photo's colors.
class _Features {
  const _Features({
    required this.lightness,
    required this.vividness,
    required this.cool,
    required this.purple,
    required this.redPink,
    required this.orange,
    required this.green,
    required this.neutral,
  });

  final double lightness; // 0 black ... 1 white
  final double vividness; // 0 gray ... 1 very colorful
  // Share of the photo (0..1) in each color family:
  final double cool; // teal and blue
  final double purple;
  final double redPink;
  final double orange; // orange and yellow
  final double green;
  final double neutral; // gray, black, white
}

class MoodEngine {
  static MoodResult analyze(List<ExtractedColor> colors) {
    const fallback = MoodResult(
      mood: Mood.chill,
      valence: 0.6,
      energy: 0.2,
    );
    if (colors.isEmpty) return fallback;
    final total = colors.fold<double>(0, (s, c) => s + c.share);
    if (total <= 0) return fallback;

    // 1. Measure the photo (every color counts by how much of the photo it covers).
    double lightness = 0, vividness = 0, warmSum = 0;
    double cool = 0, purple = 0, redPink = 0, orange = 0, green = 0, neutral = 0;
    final lights = <double>[];
    final weights = <double>[];

    for (final c in colors) {
      final w = c.share / total;
      final hsl = HSLColor.fromColor(c.color);
      // Chroma: how colorful it really is. Near-black and near-white count as gray.
      final chroma = (1 - (2 * hsl.lightness - 1).abs()) * hsl.saturation;

      lightness += w * hsl.lightness;
      vividness += w * chroma;
      // Warmth: +1 for orange hues, -1 for blue hues, weighted by chroma.
      warmSum += w * chroma * cos((hsl.hue - 30) * pi / 180);
      lights.add(hsl.lightness);
      weights.add(w);

      if (chroma < 0.12) {
        neutral += w;
        continue;
      }
      final h = hsl.hue;
      if (h >= 170 && h < 260) {
        cool += w;
      } else if (h >= 260 && h < 340) {
        purple += w;
      } else if (h >= 340 || h < 15) {
        redPink += w;
      } else if (h < 65) {
        orange += w;
      } else {
        green += w;
      }
    }

    // Contrast: how different the lights and darks are.
    var variance = 0.0;
    for (var i = 0; i < lights.length; i++) {
      variance += weights[i] * pow(lights[i] - lightness, 2);
    }
    final contrast = sqrt(variance);

    final warmth = (warmSum / max(0.3, vividness)).clamp(-1.0, 1.0);
    final warm01 = (warmth + 1) / 2; // 0 cold ... 1 warm
    final vividNorm = (vividness / 0.6).clamp(0.0, 1.0);
    final contrastNorm = (contrast / 0.3).clamp(0.0, 1.0);

    // 2. Two scores. Bright, colorful, warm = happier. Colorful, contrasty, warm = more energy.
    final valence =
    (0.08 + 0.55 * lightness + 0.25 * vividNorm + 0.12 * warm01)
        .clamp(0.0, 1.0);
    final energy = (0.08 +
        0.40 * vividNorm +
        0.20 * contrastNorm +
        0.20 * warm01 +
        0.05 * lightness)
        .clamp(0.0, 1.0);

    // 3. Closest mood wins. Color-family bonuses break ties between similar moods.
    final f = _Features(
      lightness: lightness,
      vividness: vividness,
      cool: cool,
      purple: purple,
      redPink: redPink,
      orange: orange,
      green: green,
      neutral: neutral,
    );

    var best = Mood.chill;
    var bestScore = double.infinity;
    for (final m in Mood.values) {
      final dv = valence - m.valence;
      final de = energy - m.energy;
      final score = sqrt(dv * dv + de * de) - _bonus(m, f);
      if (score < bestScore) {
        bestScore = score;
        best = m;
      }
    }

    debugPrint('MoodEngine -> ${best.label} | valence ${valence.toStringAsFixed(2)}, '
        'energy ${energy.toStringAsFixed(2)}, light ${lightness.toStringAsFixed(2)}, '
        'vivid ${vividness.toStringAsFixed(2)}');

    return MoodResult(mood: best, valence: valence, energy: energy);
  }

  /// Extra points for a mood when the photo's colors suit it. Higher = better fit.
  static double _bonus(Mood m, _Features f) {
    final dark = ((0.4 - f.lightness) / 0.25).clamp(0.0, 1.0);
    final bright = ((f.lightness - 0.4) / 0.2).clamp(0.0, 1.0);
    final paleLight = ((f.lightness - 0.6) / 0.15).clamp(0.0, 1.0);
    final darkish = ((0.65 - f.lightness) / 0.15).clamp(0.0, 1.0);
    final midLight = (1 - (f.lightness - 0.5).abs() / 0.3).clamp(0.0, 1.0);
    final lowVivid = (1 - f.vividness / 0.35).clamp(0.0, 1.0);
    final vivid = (f.vividness / 0.5).clamp(0.0, 1.0);

    switch (m) {
      case Mood.happy:
        return 0.20 * f.orange * bright;
      case Mood.romantic:
        return 0.20 * (f.redPink + 0.5 * f.purple);
      case Mood.chill:
        return 0.22 * f.cool;
      case Mood.sad:
        return 0.15 * dark * lowVivid;
      case Mood.energetic:
        return 0.20 * f.green;
      case Mood.dreamy:
        return 0.20 * f.purple + 0.12 * paleLight * lowVivid;
      case Mood.focused:
      // Bonus for gray photos, small penalty for colorful ones.
        return 0.15 * f.neutral * midLight - 0.12 * (1 - f.neutral);
      case Mood.nostalgic:
        return 0.20 * (f.orange + 0.5 * f.redPink) * lowVivid;
      case Mood.mysterious:
        return 0.20 * (f.cool + f.purple) * dark;
      case Mood.confident:
        return 0.15 * f.redPink * vivid * darkish;
    }
  }
}