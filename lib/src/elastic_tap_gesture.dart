import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:ios_fluid_interactions/src/glow_painter.dart';

import 'elastic_types.dart';
import 'spring_configs.dart';

// ============================================================================
// MAIN WIDGET
// ============================================================================

/// A widget that applies elastic spring animations on tap.
///
/// This widget provides an iOS-style "bouncy" interaction effect where:
/// - The child scales up with a quick spring effect when pressed
/// - The child deforms in the direction of drag movement (jelly effect)
/// - The child bounces back with a slower spring effect when released
/// - The [onTap] callback is triggered on release (if pointer is still inside)
///
/// ## How it works:
///
/// The widget uses 5 animation controllers to animate different properties:
/// 1. **Scale** - Overall size of the widget (1.0 = normal)
/// 2. **DeformX** - Horizontal stretch/compress (1.0 = normal)
/// 3. **DeformY** - Vertical stretch/compress (1.0 = normal)
/// 4. **ShiftX** - Horizontal position offset in pixels
/// 5. **ShiftY** - Vertical position offset in pixels
///
/// All animations use spring physics ([SpringSimulation]) for natural motion.
///
/// ## Volume Preservation (Jelly Effect):
///
/// When dragging, the widget maintains visual "volume preservation":
/// - Moving horizontally → stretches X, compresses Y
/// - Moving vertically → stretches Y, compresses X
/// - Moving diagonally → balanced (no deformation)
///
/// This creates the characteristic "jelly" or "rubber" feel.
///
class ElasticTapGesture extends StatefulWidget {
  const ElasticTapGesture({
    super.key,
    required this.child,
    this.onTap,
    this.onLongTap,
    this.scaling = Scaling.adaptive,
    this.longTapDuration = const Duration(milliseconds: 500),
    this.scaleGrowthPixels = 10.0,
    this.elasticDampingIntencity = ElasticDampingIntencity.medium,
    this.deformIntensity = DeformIntensity.medium,
    this.dragIntensity = DragIntensity.medium,
    this.showCursorGlow = false,
    this.glowColor = Colors.white,
  });

  /// Color of the glow effect.
  final Color glowColor;

  /// The widget to display and animate on tap.
  final Widget child;

  /// Called when tap is released inside the widget.
  ///
  /// NOT called if:
  /// - Pointer moves outside before release
  /// - Long tap was triggered
  final VoidCallback? onTap;

  /// Called when tap is held for [longTapDuration].
  ///
  /// When triggered, [onTap] will NOT be called on release.
  final VoidCallback? onLongTap;

  /// Scale factor when pressed (default: 1.1 = 110%).
  ///
  /// Ignored if [adaptiveScaling] is true.
  final Scaling scaling;

  /// Duration before [onLongTap] triggers (default: 500ms).
  final Duration longTapDuration;

  /// Pixel growth for adaptive scaling (default: 10.0).
  final double scaleGrowthPixels;

  /// Damping for elastic deformation animation (default: ElasticDampingIntencity.medium).
  ///
  /// - ElasticDampingIntencity.low (5.0) = more bounce, jelly-like
  /// - ElasticDampingIntencity.medium (10.0) = balanced bounce
  /// - ElasticDampingIntencity.high (20.0) = less bounce, settles quickly
  /// - ElasticDampingIntencity(value) = custom damping value
  final ElasticDampingIntencity elasticDampingIntencity;

  /// Deformation responsiveness during drag (default: DeformIntensity.medium).
  ///
  /// - DeformIntensity.low (0.5) = subtle jelly effect
  /// - DeformIntensity.medium (1.0) = balanced jelly effect
  /// - DeformIntensity.high (2.0) = dramatic jelly effect
  final DeformIntensity deformIntensity;

  /// Drag movement intensity (default: DragIntensity.medium).
  ///
  /// - DragIntensity.none = no movement
  /// - DragIntensity.low = widget follows finger less
  /// - DragIntensity.medium = normal movement
  /// - DragIntensity.high = widget follows finger more
  final DragIntensity dragIntensity;

  /// Show radial glow effect under cursor (default: false).
  final bool showCursorGlow;

  @override
  State<ElasticTapGesture> createState() => _ElasticTapGestureState();
}

// ============================================================================
// STATE
// ============================================================================

class _ElasticTapGestureState extends State<ElasticTapGesture>
    with TickerProviderStateMixin {
  // ==========================================================================
  // ANIMATION CONTROLLERS
  // ==========================================================================
  //
  // We use 5 unbounded controllers (can exceed 0-1 range for spring overshoot):
  // Index 0: Scale (1.0 = normal size)
  // Index 1: DeformX (1.0 = normal width, >1 = stretched, <1 = compressed)
  // Index 2: DeformY (1.0 = normal height)
  // Index 3: ShiftX (0.0 = no horizontal offset)
  // Index 4: ShiftY (0.0 = no vertical offset)

  late final List<AnimationController> _controllers;

  /// Convenience getters for each controller.
  AnimationController get _scale => _controllers[0];
  AnimationController get _deformX => _controllers[1];
  AnimationController get _deformY => _controllers[2];
  AnimationController get _shiftX => _controllers[3];
  AnimationController get _shiftY => _controllers[4];

  // ==========================================================================
  // GESTURE STATE
  // ==========================================================================

  /// Target scale value calculated on pointer down.
  /// Used to check if scale-up animation completed before release.
  double _targetScale = 1.0;

  /// Whether pointer is currently inside widget bounds.
  /// Determines if [onTap] should be called on release.
  bool _isInside = false;

  /// Position where pointer initially went down.
  /// Used as reference for calculating drag offset.
  Offset? _startPos;

  /// Current pointer position (for cursor glow effect).
  Offset? _cursorPos;

  // ==========================================================================
  // LONG TAP STATE
  // ==========================================================================

  /// Timer that triggers [onLongTap] after [longTapDuration].
  Timer? _longTapTimer;

  /// Whether long tap was triggered (prevents [onTap] on release).
  bool _longTapFired = false;

  /// Disposal flag to prevent setState after dispose.
  bool _disposed = false;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    // Initial values: [scale, deformX, deformY, shiftX, shiftY]
    final initialValues = [1.0, 1.0, 1.0, 0.0, 0.0];

    // Create all controllers using factory method
    _controllers = [
      for (final initial in initialValues) _createController(initial),
    ];
  }

  /// Factory method to create an unbounded animation controller.
  ///
  /// - Uses unbounded because spring animations can overshoot (value > target)
  /// - Adds listener that calls setState when value changes
  /// - Includes safety checks: not disposed, mounted, finite value
  AnimationController _createController(double initial) {
    final controller = AnimationController.unbounded(
      vsync: this,
      value: initial,
    );

    controller.addListener(() {
      // Safety checks before rebuilding:
      // 1. Widget not disposed (prevents "setState after dispose" error)
      // 2. Widget still in tree (mounted)
      // 3. Value is valid (not NaN or Infinity from spring edge cases)
      if (!_disposed && mounted && controller.value.isFinite) {
        setState(() {});
      }
    });

    return controller;
  }

  @override
  void dispose() {
    // Set flag FIRST to prevent animation listeners from calling setState
    _disposed = true;

    // Cancel long tap timer
    _longTapTimer?.cancel();

    // Stop and dispose all controllers
    for (final controller in _controllers) {
      controller.stop();
      controller.dispose();
    }

    super.dispose();
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Stops all animation controllers.
  void _stopAll() {
    for (final controller in _controllers) {
      controller.stop();
    }
  }

  /// Animates a controller to target value using spring physics.
  ///
  /// [controller] - The animation controller to animate
  /// [target] - Target value to animate to
  /// [spring] - Spring configuration (mass, stiffness, damping)
  void _springTo(
    AnimationController controller,
    double target,
    SpringDescription spring,
  ) {
    final simulation = SpringSimulation(
      spring,
      controller.value, // Start from current value
      target, // End at target
      0, // Initial velocity (0 = start from rest)
    );
    controller.animateWith(simulation);
  }

  /// Returns value if finite and positive, otherwise returns fallback.
  /// Used to prevent rendering errors from invalid animation values.
  double _safe(double value, double fallback) =>
      value.isFinite && value > 0 ? value : fallback;

  // ==========================================================================
  // GESTURE HANDLERS
  // ==========================================================================

  /// Handles pointer down (touch start).
  ///
  /// 1. Records initial position
  /// 2. Stops any running animations
  /// 3. Calculates target scale (adaptive or fixed)
  /// 4. Starts scale-up spring animation
  /// 5. Starts long tap timer
  void _onPointerDown(PointerDownEvent event) {
    if (_disposed) return;

    // Record initial state
    _isInside = true;
    _startPos = event.localPosition;
    _cursorPos = event.localPosition;
    _longTapFired = false;

    // Stop any running animations to start fresh
    _stopAll();

    // --- Calculate target scale ---
    if (widget.scaling == Scaling.adaptive) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        // Use diagonal for consistent behavior regardless of aspect ratio
        // diagonal = sqrt(width² + height²)
        final diagonal = sqrt(pow(box.size.width, 2) + pow(box.size.height, 2));

        // Smaller widgets get larger scale factors (more noticeable growth)
        // Larger widgets get smaller scale factors (subtle growth)
        // This creates consistent PIXEL increase across all sizes
        _targetScale = 1.0 + (widget.scaleGrowthPixels / diagonal);
      }
    } else {
      _targetScale = widget.scaling.value;
    }

    // Start scale-up animation with quick, snappy spring
    _springTo(_scale, _targetScale, FluidSprings.press);

    // Start long tap timer if callback provided
    if (widget.onLongTap != null) {
      _longTapTimer?.cancel();
      _longTapTimer = Timer(widget.longTapDuration, _onLongTap);
    }
  }

  /// Handles pointer move (drag).
  ///
  /// Creates the "jelly effect" by:
  /// 1. Checking if pointer is still inside bounds
  /// 2. Calculating drag offset from start position
  /// 3. Computing deformation with volume preservation
  /// 4. Updating values immediately (no animation during drag)
  void _onPointerMove(PointerEvent event) {
    if (_disposed || _startPos == null) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final pos = event.localPosition;
    _cursorPos = pos;

    // Check if pointer is inside widget bounds
    _isInside = Rect.fromLTWH(
      0,
      0,
      box.size.width,
      box.size.height,
    ).contains(pos);

    // Calculate drag offset from start position
    final drag = pos - _startPos!;

    // ========================================================================
    // JELLY EFFECT CALCULATION
    // ========================================================================
    //
    // The jelly effect stretches the widget in the drag direction while
    // compressing it perpendicular. This maintains visual "volume".
    //
    // Example:
    //   Drag right → stretch horizontally, compress vertically
    //   Drag down → stretch vertically, compress horizontally
    //   Drag diagonal → balanced (minimal deformation)

    // Base sensitivity values
    const baseFactor = 5000.0; // Higher = less sensitive to drag
    const maxDeform = 0.15; // Maximum 15% deformation
    const baseShift = 0.02; // Base translation amount

    // Apply user intensity multipliers
    final factor = baseFactor / widget.deformIntensity.value;
    final max = maxDeform * widget.deformIntensity.value;
    final shift = baseShift * widget.dragIntensity.value;

    // Calculate raw deformation for each axis (0 to max)
    // Uses absolute value - we care about distance, not direction
    final dx = (drag.dx.abs() / factor).clamp(0.0, max);
    final dy = (drag.dy.abs() / factor).clamp(0.0, max);

    // Volume preservation: difference determines which axis dominates
    // - Positive diff = more horizontal movement → stretch X, compress Y
    // - Negative diff = more vertical movement → stretch Y, compress X
    // - Zero diff = diagonal movement → no deformation
    final diff = (dx - dy).clamp(-max, max);

    // Update controller values directly (no animation during drag)
    // Animation only happens on release via _animateToRest()
    _deformX.value = 1.0 + diff; // Stretch if positive
    _deformY.value = 1.0 - diff; // Compress if X stretches
    _shiftX.value = drag.dx * shift;
    _shiftY.value = drag.dy * shift;

    setState(() {});
  }

  /// Handles pointer up (touch end).
  ///
  /// 1. Cancels long tap timer
  /// 2. Waits for scale-up animation if needed (visual feedback)
  /// 3. Animates back to rest state
  /// 4. Calls [onTap] if pointer was inside and no long tap
  Future<void> _onPointerUp(PointerUpEvent event) async {
    _longTapTimer?.cancel();

    // Ensure scale-up animation is visible before returning
    // If user taps very quickly, wait for animation to be noticeable
    const threshold = 0.02; // 2% tolerance
    if ((_scale.value - _targetScale).abs() > threshold) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Animate all values back to rest
    _animateToRest();

    // Call onTap if released inside and no long tap
    if (_isInside && !_longTapFired) {
      try {
        widget.onTap?.call();
      } catch (e) {}
    }

    _resetState();
  }

  /// Handles pointer cancel (gesture interrupted).
  ///
  /// Called when gesture is cancelled by scrolling, another gesture,
  /// or system interrupt. Simply animates back and resets.
  void _onPointerCancel(PointerCancelEvent event) {
    if (_disposed) return;

    _longTapTimer?.cancel();
    _animateToRest();
    _resetState();
  }

  /// Handles long tap trigger.
  ///
  /// Called by timer after [longTapDuration].
  /// Sets flag to prevent [onTap] from being called.
  void _onLongTap() {
    if (_disposed || !_isInside) return;

    _longTapFired = true;
    widget.onLongTap?.call();
  }

  // ==========================================================================
  // ANIMATION
  // ==========================================================================

  /// Animates all values back to their resting state.
  ///
  /// Uses different springs for different properties:
  /// - Scale: Slower, smoother (release spring)
  /// - Deform/Shift: User-configurable bounce (elastic spring)
  void _animateToRest() {
    if (_disposed) return;

    final elastic = FluidSprings.elastic(widget.elasticDampingIntencity);

    // Scale returns with smooth spring (less bounce)
    _springTo(_scale, 1.0, FluidSprings.release);

    // Deformation and shift return with bouncy spring
    _springTo(_deformX, 1.0, elastic);
    _springTo(_deformY, 1.0, elastic);
    _springTo(_shiftX, 0.0, elastic);
    _springTo(_shiftY, 0.0, elastic);
  }

  /// Resets gesture state variables.
  void _resetState() {
    _isInside = false;
    _startPos = null;
    _cursorPos = null;
    _longTapFired = false;
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    // Safety check: return plain child if disposed
    if (_disposed) return widget.child;

    // --- Get safe animation values ---
    // Spring animations can produce NaN/Infinity in edge cases
    final scale = _safe(_scale.value, 1.0);
    final deformX = _safe(_deformX.value, 1.0);
    final deformY = _safe(_deformY.value, 1.0);
    final shiftX = _shiftX.value.isFinite ? _shiftX.value : 0.0;
    final shiftY = _shiftY.value.isFinite ? _shiftY.value : 0.0;

    // Combine scale and deformation
    // Final size = base scale × deformation
    final scaleX = scale * deformX;
    final scaleY = scale * deformY;

    // Fallback if combined values are invalid
    if (!scaleX.isFinite || !scaleY.isFinite) {
      return _buildListener(child: widget.child);
    }

    // --- Build transformation matrix ---
    // Combines translation (shift) and scale in one matrix
    //
    // translateByDouble(x, y, z, w) - w=1.0 is homogeneous coordinate
    // scaleByDouble(x, y, z, w) - scales each axis independently
    final matrix = Matrix4.identity()
      ..translateByDouble(shiftX, shiftY, 0, 1)
      ..scaleByDouble(scaleX, scaleY, 1, 1);

    return _buildListener(
      child: Transform(
        transform: matrix,
        alignment: Alignment.center, // Scale from center
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.passthrough, // Stack takes child's size
          children: [
            widget.child,

            // Optional cursor glow effect
            if (_cursorPos != null && widget.showCursorGlow)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: GlowPainter(_cursorPos!, widget.glowColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Wraps child with Listener for pointer events.
  Widget _buildListener({required Widget child}) {
    return Listener(
      // Translucent allows gestures to pass through to children
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: child,
    );
  }
}
