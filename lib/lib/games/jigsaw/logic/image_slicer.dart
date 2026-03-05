// Image slicing utilities for jigsaw puzzle.
// This module handles the visual representation of puzzle pieces.

import 'dart:ui' as ui;

class ImageSlicer {
  ImageSlicer._();

  /// Calculates the source rectangle for a piece from the original image.
  static ui.Rect getPieceRect({
    required int row,
    required int col,
    required int gridSize,
    required double imageWidth,
    required double imageHeight,
  }) {
    final pieceWidth = imageWidth / gridSize;
    final pieceHeight = imageHeight / gridSize;
    return ui.Rect.fromLTWH(
      col * pieceWidth,
      row * pieceHeight,
      pieceWidth,
      pieceHeight,
    );
  }

  /// Downscales image dimensions while maintaining aspect ratio.
  static (double, double) downscale({
    required double width,
    required double height,
    required double maxSize,
  }) {
    if (width <= maxSize && height <= maxSize) {
      return (width, height);
    }

    final ratio = width / height;
    if (width > height) {
      return (maxSize, maxSize / ratio);
    } else {
      return (maxSize * ratio, maxSize);
    }
  }
}

/// Represents color data for a puzzle piece when no image is loaded.
class PieceColorData {
  final int row;
  final int col;
  final int gridSize;

  const PieceColorData({
    required this.row,
    required this.col,
    required this.gridSize,
  });

  /// Generates a gradient color based on position.
  int get colorValue {
    final hue = ((row * gridSize + col) / (gridSize * gridSize)) * 360;
    return _hslToRgb(hue, 0.6, 0.7);
  }

  static int _hslToRgb(double h, double s, double l) {
    final c = (1 - (2 * l - 1).abs()) * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = l - c / 2;

    double r, g, b;
    if (h < 60) {
      r = c; g = x; b = 0;
    } else if (h < 120) {
      r = x; g = c; b = 0;
    } else if (h < 180) {
      r = 0; g = c; b = x;
    } else if (h < 240) {
      r = 0; g = x; b = c;
    } else if (h < 300) {
      r = x; g = 0; b = c;
    } else {
      r = c; g = 0; b = x;
    }

    final ri = ((r + m) * 255).round();
    final gi = ((g + m) * 255).round();
    final bi = ((b + m) * 255).round();

    return 0xFF000000 | (ri << 16) | (gi << 8) | bi;
  }
}
