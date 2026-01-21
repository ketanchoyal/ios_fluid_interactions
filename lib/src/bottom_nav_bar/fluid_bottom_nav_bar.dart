import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:ios_fluid_interactions/ios_fluid_interactions.dart';

import '../elastic_types.dart';
import '../glow.dart';
import '../spring_configs.dart';
import 'fluid_nav_destination.dart';
import 'fluid_nav_theme.dart';
import 'fluid_trailing_action_button.dart';

/// Callback type for navigation tap events.
typedef NavTapCallback = void Function(int index);

/// Builder for creating custom navigation item widgets.
typedef NavItemBuilder =
    Widget Function(
      BuildContext context,
      int index,
      FluidNavDestination destination,
      bool isActive,
    );

// ============================================================================
// FLUID BOTTOM NAV BAR
// ============================================================================

class FluidBottomNavBar extends StatefulWidget {
  const FluidBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.shrinkNotifier,
    required this.destinations,
    this.theme,
    this.floatingWidget,
    this.floatingWidgetTabIndex,
    this.trailingButtonConfig,
    this.trailingWidget,
    this.enableGlow = true,
    this.itemBuilder,
    this.scaling = Scaling.adaptive,
    this.elasticDampingIntensity = ElasticDampingIntencity.medium,
    this.deformIntensity = DeformIntensity.medium,
    this.dragIntensity = DragIntensity.medium,
    this.scaleGrowthPixels = 10.0,
  });

  final int currentIndex;
  final NavTapCallback onTap;
  final ValueNotifier<bool> shrinkNotifier;
  final List<FluidNavDestination> destinations;
  final FluidBottomNavBarTheme? theme;
  final Widget? floatingWidget;
  final int? floatingWidgetTabIndex;
  final FluidTrailingActionButtonConfig? trailingButtonConfig;
  final Widget? trailingWidget;
  final bool enableGlow;
  final NavItemBuilder? itemBuilder;

  // Elastic physics configuration
  final Scaling scaling;
  final ElasticDampingIntencity elasticDampingIntensity;
  final DeformIntensity deformIntensity;
  final DragIntensity dragIntensity;
  final double scaleGrowthPixels;

  @override
  State<FluidBottomNavBar> createState() => _FluidBottomNavBarState();
}

class _FluidBottomNavBarState extends State<FluidBottomNavBar>
    with TickerProviderStateMixin {
  // ============================================================================
  // ELASTIC ANIMATION CONTROLLERS
  // ============================================================================

  late final List<AnimationController> _elasticControllers;
  AnimationController get _scale => _elasticControllers[0];
  AnimationController get _deformX => _elasticControllers[1];
  AnimationController get _deformY => _elasticControllers[2];
  AnimationController get _shiftX => _elasticControllers[3];
  AnimationController get _shiftY => _elasticControllers[4];

  bool _isInside = false;
  Offset? _startPos;
  bool _disposed = false;

  /// Current pointer position (for cursor glow effect).
  Offset? _cursorPos;

  // ============================================================================
  // HIGHLIGHT GESTURE STATE
  // ============================================================================

  int? _highlightedIndex;
  final _highlightedRect = ValueNotifier<Rect?>(null);
  final List<GlobalKey> _navItemKeys = [];
  bool _isDragging = false;

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void initState() {
    super.initState();

    final initialValues = [1.0, 1.0, 1.0, 0.0, 0.0];
    _elasticControllers = [
      for (final initial in initialValues) _createController(initial),
    ];

    _navItemKeys.addAll(
      List.generate(widget.destinations.length, (_) => GlobalKey()),
    );
  }

  AnimationController _createController(double initial) {
    final controller = AnimationController.unbounded(
      vsync: this,
      value: initial,
    );
    controller.addListener(() {
      if (!_disposed && mounted && controller.value.isFinite) {
        setState(() {});
      }
    });
    return controller;
  }

  @override
  void dispose() {
    _disposed = true;
    for (final controller in _elasticControllers) {
      controller.stop();
      controller.dispose();
    }
    _highlightedRect.dispose();
    super.dispose();
  }

  // ============================================================================
  // ELASTIC ANIMATION HELPERS
  // ============================================================================

  void _stopAll() {
    for (final controller in _elasticControllers) {
      controller.stop();
    }
  }

  void _springTo(
    AnimationController controller,
    double target,
    SpringDescription spring,
  ) {
    final simulation = SpringSimulation(spring, controller.value, target, 0);
    controller.animateWith(simulation);
  }

  double _safe(double value, double fallback) =>
      value.isFinite && value > 0 ? value : fallback;

  void _scaleUp() {
    double targetScale;

    if (widget.scaling == Scaling.adaptive) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        final diagonal = sqrt(pow(box.size.width, 2) + pow(box.size.height, 2));
        targetScale = 1.0 + (widget.scaleGrowthPixels / diagonal);
      } else {
        targetScale = 1.05; // Fallback
      }
    } else {
      targetScale = widget.scaling.value;
    }

    _springTo(_scale, targetScale, FluidSprings.press);
  }

  void _animateToRest() {
    if (_disposed) return;

    // Use configured damping intensity
    final elasticSpring = FluidSprings.elastic(widget.elasticDampingIntensity);

    _springTo(_scale, 1.0, FluidSprings.release);
    _springTo(_deformX, 1.0, elasticSpring);
    _springTo(_deformY, 1.0, elasticSpring);
    _springTo(_shiftX, 0.0, elasticSpring);
    _springTo(_shiftY, 0.0, elasticSpring);
  }

  // ============================================================================
  // HIGHLIGHT GESTURE HELPERS
  // ============================================================================

  int? _getItemIndexAtPosition(Offset globalPosition) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final localPosition = renderBox.globalToLocal(globalPosition);
    if (!renderBox.paintBounds.contains(localPosition)) return null;

    for (int i = 0; i < _navItemKeys.length; i++) {
      final box =
          _navItemKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final itemLocalPos = box.globalToLocal(globalPosition);
        if (box.paintBounds.contains(itemLocalPos)) {
          return i;
        }
      }
    }
    return null;
  }

  void _updateHighlightedRect(int index) {
    final box =
        _navItemKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final parentBox = context.findRenderObject() as RenderBox?;
      if (parentBox != null) {
        final topLeft = box.localToGlobal(Offset.zero);
        final relativeOffset = parentBox.globalToLocal(topLeft);
        _highlightedRect.value = relativeOffset & box.size;
      }
    }
  }

  void _clearHighlight() {
    // Just clear the visual highlight, don't stop dragging state
    if (!mounted) return;
    _highlightedRect.value = null;

    Future.delayed(const Duration(milliseconds: 200)).then((_) {
      if (mounted && _highlightedRect.value == null) {
        setState(() {
          _highlightedIndex = null;
        });
      }
    });
  }

  void _deselectHighlighting() {
    if (!mounted) return;
    _isDragging = false; // Stop dragging state
    _clearHighlight();
  }

  // ============================================================================
  // GESTURE HANDLERS
  // ============================================================================

  void _handlePointerDown(PointerDownEvent event) {
    if (_disposed) return;
    _cursorPos = event.localPosition;

    _stopAll();

    final index = _getItemIndexAtPosition(event.position);
    if (index != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isDragging = true;
        _highlightedIndex = index;
        _startPos = event.localPosition;
        _isInside = true;
      });
      _updateHighlightedRect(index);
    }
    _scaleUp();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_disposed) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final pos = event.localPosition;
    _cursorPos = pos;

    final isInsideNow = Rect.fromLTWH(
      0,
      0,
      box.size.width,
      box.size.height,
    ).contains(pos);

    // If exited bounds
    if (_isInside && !isInsideNow) {
      _isInside = false;
      _animateToRest();
      _clearHighlight(); // Only clear visual, keep _isDragging true
      return;
    }

    // If entered bounds
    final bool justReEntered = !_isInside && isInsideNow;
    if (justReEntered) {
      _isInside = true;
      setState(() {});
    }

    // Highlight tracking logic
    if (_isDragging) {
      final index = _getItemIndexAtPosition(event.position);

      // Update highlight if we moved to a new valid index OR just re-entered
      if (index != null && (index != _highlightedIndex || justReEntered)) {
        setState(() {
          _highlightedIndex = index;
        });
        _updateHighlightedRect(index);

        // Optional: Trigger light haptic on re-entry/change
        if (justReEntered || index != _highlightedIndex) {
          HapticFeedback.selectionClick();
        }
      }
    }

    if (_isInside && _startPos != null) {
      final drag = pos - _startPos!;

      const baseFactor = 3000.0;
      const maxDeform = 0.15;
      const baseShift = 0.05;

      final factor = baseFactor / widget.deformIntensity.value;
      final max = maxDeform * widget.deformIntensity.value;
      final shift = baseShift * widget.dragIntensity.value;

      final dx = (drag.dx.abs() / factor).clamp(0.0, max);
      final dy = (drag.dy.abs() / factor).clamp(0.0, max);
      final diff = (dx - dy).clamp(-max, max);

      _deformX.value = 1.0 + diff;
      _deformY.value = 1.0 - diff;
      _shiftX.value = drag.dx * shift;
      _shiftY.value = drag.dy * shift;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_disposed) return;

    final index = _getItemIndexAtPosition(event.position);

    if (index != null && index == _highlightedIndex) {
      _handleTap(index);
    }

    _animateToRest();
    _deselectHighlighting();
    setState(() {
      _isInside = false;
      _startPos = null;
      _cursorPos = null;
    });
  }

  void _handleTap(int index) {
    if (widget.shrinkNotifier.value) {
      widget.shrinkNotifier.value = false;
      return;
    }

    if (index == widget.currentIndex) {
      widget.shrinkNotifier.value = true;
      return;
    }

    widget.onTap(index);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_disposed) return;
    _animateToRest();
    _deselectHighlighting();
    setState(() {
      _isInside = false;
      _startPos = null;
      _cursorPos = null;
    });
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final resolvedTheme =
        widget.theme?.resolve() ?? FluidBottomNavBarTheme().resolve();

    final scale = _safe(_scale.value, 1.0);
    final deformX = _safe(_deformX.value, 1.0);
    final deformY = _safe(_deformY.value, 1.0);
    final shiftX = _shiftX.value.isFinite ? _shiftX.value : 0.0;
    final shiftY = _shiftY.value.isFinite ? _shiftY.value : 0.0;

    final scaleX = scale * deformX;
    final scaleY = scale * deformY;

    final matrix = Matrix4.identity()
      ..translateByDouble(shiftX, shiftY, 0, 1)
      ..scaleByDouble(scaleX, scaleY, 1, 1);

    return ElasticTapGesture(
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.shrinkNotifier,
        builder: (context, isShrunk, child) {
          final showFloating =
              widget.floatingWidget != null &&
              isShrunk &&
              (widget.floatingWidgetTabIndex == null ||
                  widget.currentIndex == widget.floatingWidgetTabIndex);

          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _handlePointerDown,
                onPointerMove: _handlePointerMove,
                onPointerUp: _handlePointerUp,
                onPointerCancel: _handlePointerCancel,
                child: Transform(
                  transform: matrix,
                  alignment: Alignment.center,
                  child: _buildNavBarContainer(resolvedTheme, isShrunk),
                ),
              ),
              if (widget.floatingWidget != null)
                Flexible(
                  child: AnimatedOpacity(
                    duration: resolvedTheme.opacityAnimationDuration,
                    opacity: showFloating ? 1.0 : 0.0,
                    child: showFloating
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: widget.floatingWidget!,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              if (widget.trailingWidget != null)
                widget.trailingWidget!
              else if (widget.trailingButtonConfig != null)
                FluidTrailingActionButton(
                  currentIndex: widget.currentIndex,
                  config: widget.trailingButtonConfig!,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavBarContainer(
    ResolvedFluidBottomNavBarTheme theme,
    bool isShrunk,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(theme.borderRadius)),
      child: Glow(
        enabled: widget.enableGlow,
        child: Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                blurRadius: theme.shadowBlurRadius,
                spreadRadius: theme.shadowSpreadRadius,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(theme.borderRadius)),
            border: Border.all(
              color: theme.borderColor.withValues(alpha: theme.borderAlpha),
              width: 0.1,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Stack(
              children: [
                // Highlight overlay
                // ValueListenableBuilder<Rect?>(
                //   valueListenable: _highlightedRect,
                //   builder: (context, rect, child) {
                //     if (rect == null) return const SizedBox.shrink();
                //     return AnimatedPositioned.fromRect(
                //       rect: rect,
                //       duration: const Duration(milliseconds: 150),
                //       curve: Curves.fastOutSlowIn,
                //       child: Container(
                //         decoration: BoxDecoration(
                //           color: Colors.white.withValues(alpha: 0.1),
                //           borderRadius: BorderRadius.circular(25),
                //         ),
                //       ),
                //     );
                //   },
                // ),

                // Nav items
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int i = 0; i < widget.destinations.length; i++)
                      _buildNavItem(
                        key: _navItemKeys[i],
                        index: i,
                        destination: widget.destinations[i],
                        isShrunk: isShrunk,
                        theme: theme,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required Key key,
    required int index,
    required FluidNavDestination destination,
    required bool isShrunk,
    required ResolvedFluidBottomNavBarTheme theme,
  }) {
    final isSelected = widget.currentIndex == index;
    // Show label if selected OR if nav bar is NOT shrunk
    final isVisible = isSelected || !isShrunk;
    final isHighlighted = _highlightedIndex == index;

    final displayIcon = isSelected && destination.filledIcon != null
        ? destination.filledIcon!
        : destination.icon;

    return Container(
      key: key,
      child: ClipRect(
        child: AnimatedAlign(
          alignment: Alignment.centerLeft,
          duration: theme.shrinkAnimationDuration,
          curve: Curves.easeOutCubic,
          widthFactor: isVisible ? 1.0 : 0.0,
          heightFactor: 1.0,
          child: AnimatedOpacity(
            duration: theme.opacityAnimationDuration,
            opacity: isVisible ? 1.0 : 0.0,
            child: widget.itemBuilder != null
                ? widget.itemBuilder!(context, index, destination, isSelected)
                : FluidNavItem(
                    icon: displayIcon,
                    label: destination.label,
                    isActive: isSelected,
                    isHighlighted: isHighlighted,
                    theme: theme,
                    position: _cursorPos,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isHighlighted,
    required ResolvedFluidBottomNavBarTheme theme,
  }) {
    final activeColor = isActive
        ? theme.iconActiveColor
        : theme.iconInactiveColor;
    final activeLabelColor = isActive
        ? theme.labelActiveColor
        : theme.labelInactiveColor;

    // Scale up slightly when highlighted
    final double scale = isHighlighted ? 1.1 : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2.5),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2.5),
            child: SizedBox(
              width: theme.navItemWidth,
              height: 50, // Fixed height for nav item
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  AnimatedScale(
                    scale: isActive ? 1.3 : 1.0,
                    duration: theme.scaleAnimationDuration,
                    curve: Curves.elasticOut,
                    child: Icon(icon, size: theme.iconSize, color: activeColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AnimatedScale(
                      scale: isActive ? 1.1 : 1.0,
                      duration: theme.scaleAnimationDuration,
                      curve: Curves.elasticOut,
                      child: Text(
                        label,
                        style: theme.labelTextStyle.copyWith(
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: activeLabelColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
