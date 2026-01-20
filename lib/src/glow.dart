import 'package:flutter/material.dart';
import 'package:ios_fluid_interactions/src/glow_painter.dart';

/// A widget that adds a radial glow effect overlay to its child.
///
/// Wraps any widget with a subtle radial glow that follows pointer position.
/// Much simpler than [CursorGlow] - just a visual overlay with auto-tracking.
///
/// ## Example
///
/// ```dart
/// Glow(
///   enabled: true,
///   child: Container(
///     width: 100,
///     height: 100,
///     color: Colors.blue,
///   ),
/// )
/// ```
///
/// ## With custom styling
///
/// ```dart
/// Glow(
///   enabled: true,
///   radius: 300.0,
///   color: Colors.blue,
///   blendMode: BlendMode.color,
///   child: MyWidget(),
/// )
/// ```
class Glow extends StatefulWidget {
  const Glow({
    super.key,
    this.enabled = true,
    this.color = Colors.white,
    required this.child,
  });

  /// Whether glow effect is enabled.
  final bool enabled;

  /// Color of glow.
  final Color color;

  /// Widget to add glow to.
  final Widget child;

  @override
  State<Glow> createState() => _GlowState();
}

// ============================================================================
// STATE
// ============================================================================

class _GlowState extends State<Glow> {
  /// Current pointer position for glow center.
  Offset? _position;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (_position != null)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: GlowPainter(_position!, widget.color),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // GESTURE HANDLERS
  // ==========================================================================

  /// Handles pointer down (touch start).
  ///
  /// Records pointer position as glow center.
  void _onPointerDown(PointerDownEvent event) {
    setState(() => _position = event.localPosition);
  }

  /// Handles pointer move (drag).
  ///
  /// Updates glow position to follow pointer.
  void _onPointerMove(PointerMoveEvent event) {
    if (_position != null) {
      setState(() => _position = event.localPosition);
    }
  }

  /// Handles pointer up (touch end).
  ///
  /// Hides glow effect.
  void _onPointerUp(PointerUpEvent event) {
    setState(() => _position = null);
  }

  /// Handles pointer cancel (gesture interrupted).
  ///
  /// Hides glow effect.
  void _onPointerCancel(PointerCancelEvent event) {
    setState(() => _position = null);
  }
}
