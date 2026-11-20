import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// One dominant color and how much of the photo it covers (share: 0.0 to 1.0).
class ExtractedColor {
  const ExtractedColor(this.color, this.share);
  final Color color;
  final double share;
}

class _Cluster {
  _Cluster(this.r, this.g, this.b, this.count);
  double r, g, b;
  int count;

  double distanceTo(_Cluster o) {
    final dr = r - o.r, dg = g - o.g, db = b - o.b;
    return sqrt(dr * dr + dg * dg + db * db);
  }
}

class ColorExtractor {
  static const int _sampleWidth = 96; // photo is shrunk to this width first
  static const int _startClusters = 10; // groups before merging
  static const double _mergeDistance = 40; // bigger = fewer, more different colors
  static const double _minShare = 0.015; // ignore colors under 1.5% of the photo

  static Future<List<ExtractedColor>> extract(
      String path, {
        int maxColors = 6,
      }) async {
    final bytes = await File(path).readAsBytes();
    final codec =
    await ui.instantiateImageCodec(bytes, targetWidth: _sampleWidth);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    codec.dispose();
    if (data == null) return const [];

    final rgba =
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final r = <double>[], g = <double>[], b = <double>[];
    for (var i = 0; i + 3 < rgba.length; i += 4) {
      if (rgba[i + 3] < 128) continue; // skip transparent pixels
      r.add(rgba[i].toDouble());
      g.add(rgba[i + 1].toDouble());
      b.add(rgba[i + 2].toDouble());
    }
    final n = r.length;
    if (n == 0) return const [];

    final clusters = _kMeans(r, g, b, _startClusters);

    // Merge colors that look almost the same, biggest groups first.
    final sorted = clusters.where((c) => c.count > 0).toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final merged = <_Cluster>[];
    for (final c in sorted) {
      _Cluster? near;
      var best = _mergeDistance;
      for (final m in merged) {
        final d = m.distanceTo(c);
        if (d < best) {
          best = d;
          near = m;
        }
      }
      if (near == null) {
        merged.add(c);
      } else {
        final total = near.count + c.count;
        near.r = (near.r * near.count + c.r * c.count) / total;
        near.g = (near.g * near.count + c.g * c.count) / total;
        near.b = (near.b * near.count + c.b * c.count) / total;
        near.count = total;
      }
    }

    final result = merged.where((c) => c.count / n >= _minShare).toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return result
        .take(maxColors)
        .map((c) => ExtractedColor(
      Color.fromARGB(
        255,
        c.r.round().clamp(0, 255),
        c.g.round().clamp(0, 255),
        c.b.round().clamp(0, 255),
      ),
      c.count / n,
    ))
        .toList();
  }

  static double _sq(double a, double b, double c) => a * a + b * b + c * c;

  static List<_Cluster> _kMeans(
      List<double> r,
      List<double> g,
      List<double> b,
      int k,
      ) {
    final n = r.length;
    final rnd = Random(7); // fixed seed: same photo gives same colors

    // Pick starting centers far away from each other (k-means++).
    final centers = <_Cluster>[];
    final first = rnd.nextInt(n);
    centers.add(_Cluster(r[first], g[first], b[first], 0));
    final minDist = List<double>.filled(n, double.infinity);
    while (centers.length < k) {
      final last = centers.last;
      var total = 0.0;
      for (var i = 0; i < n; i++) {
        final d = _sq(r[i] - last.r, g[i] - last.g, b[i] - last.b);
        if (d < minDist[i]) minDist[i] = d;
        total += minDist[i];
      }
      if (total == 0) break; // all remaining pixels match an existing center
      var target = rnd.nextDouble() * total;
      var pick = n - 1;
      for (var i = 0; i < n; i++) {
        target -= minDist[i];
        if (target <= 0) {
          pick = i;
          break;
        }
      }
      centers.add(_Cluster(r[pick], g[pick], b[pick], 0));
    }

    // Repeat: assign each pixel to nearest center, then move the centers.
    for (var iter = 0; iter < 12; iter++) {
      final sumR = List<double>.filled(centers.length, 0);
      final sumG = List<double>.filled(centers.length, 0);
      final sumB = List<double>.filled(centers.length, 0);
      final counts = List<int>.filled(centers.length, 0);

      for (var i = 0; i < n; i++) {
        var bestIndex = 0;
        var bestDist = double.infinity;
        for (var c = 0; c < centers.length; c++) {
          final d = _sq(r[i] - centers[c].r, g[i] - centers[c].g,
              b[i] - centers[c].b);
          if (d < bestDist) {
            bestDist = d;
            bestIndex = c;
          }
        }
        sumR[bestIndex] += r[i];
        sumG[bestIndex] += g[i];
        sumB[bestIndex] += b[i];
        counts[bestIndex]++;
      }

      for (var c = 0; c < centers.length; c++) {
        centers[c].count = counts[c];
        if (counts[c] > 0) {
          centers[c].r = sumR[c] / counts[c];
          centers[c].g = sumG[c] / counts[c];
          centers[c].b = sumB[c] / counts[c];
        }
      }
    }
    return centers;
  }
}