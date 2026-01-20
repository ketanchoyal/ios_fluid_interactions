// ============================================================================
// GLOW PAINTER
// ============================================================================

import 'package:flutter/material.dart';

/// Paints a radial glow effect at a specified center point.
///
/// Creates a subtle highlight under user's finger using:
/// - RadialGradient from color to transparent
/// - Configurable blend mode for different effects
class GlowPainter extends CustomPainter {
  GlowPainter(this.center, this.color);

  /// Center point of the glow (cursor position).
  final Offset center;
  final Color color;

  /// Radius of the glow effect in pixels.
  static const _radius = 250.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color, // Bright center
          Colors.transparent, // Fades to invisible
        ],
      ).createShader(Rect.fromCircle(center: center, radius: _radius))
      ..blendMode = BlendMode.overlay; // Subtle brightness, not solid white

    canvas.drawCircle(center, _radius, paint);
  }

  @override
  bool shouldRepaint(GlowPainter old) => old.center != center;
}
