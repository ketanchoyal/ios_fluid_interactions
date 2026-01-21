import 'package:flutter/material.dart';

import '../elastic_tap_gesture.dart';

/// Callback type for trailing action button tap events with index.
typedef TrailingActionTapCallback = void Function(int index);

/// Configuration for [FluidTrailingActionButton] styling.
///
/// All parameters have sensible defaults. You can provide either a single
/// `icon` (used for all tabs) or an `iconBuilder` (for different
/// icons per tab).
///
/// ## Example (single icon)
///
/// ```dart
/// FluidTrailingActionButtonConfig(
///   icon: Icons.add,
///   onTap: (index) => print('Tapped on tab $index'),
/// )
/// ```
///
/// ## Example (different icons per tab)
///
/// ```dart
/// FluidTrailingActionButtonConfig(
///   iconBuilder: (index) {
///     if (index == 0) return Icons.home;
///     if (index == 1) return Icons.add;
///     return Icons.settings;
///   },
///   onTap: (index) => print('Tapped on tab $index'),
/// )
/// ```
class FluidTrailingActionButtonConfig {
  const FluidTrailingActionButtonConfig({
    this.icon,
    this.iconBuilder,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
    this.borderColorAlpha = 0.4,
    this.shadowColor,
    this.shadowBlurRadius = 20,
    this.shadowSpreadRadius = 1,
    this.size = 56,
    this.iconSize = 26,
    this.showCursorGlow = true,
    this.borderRadius = 40,
  });

  /// Single icon to use for all tabs.
  /// If provided, `iconBuilder` is ignored.
  final IconData? icon;

  /// Builder function to provide icon based on current tab index.
  /// If provided along with `icon`, this takes precedence.
  final IconData Function(int index)? iconBuilder;

  /// Called when button is tapped. Includes current tab index.
  final TrailingActionTapCallback onTap;

  /// Background color of button.
  /// Default: primary color (green #4CAF50)
  final Color? backgroundColor;

  /// Icon color.
  /// Default: white
  final Color? iconColor;

  /// Border color.
  /// Default: [backgroundColor]
  final Color? borderColor;

  /// Alpha/transparency for border color (0.0 - 1.0).
  /// Default: 0.4
  final double borderColorAlpha;

  /// Shadow color.
  /// Default: [backgroundColor]
  final Color? shadowColor;

  /// Blur radius for shadow.
  /// Default: 20
  final double shadowBlurRadius;

  /// Spread radius for shadow.
  /// Default: 1
  final double shadowSpreadRadius;

  /// Size of button (width/height).
  /// Default: 60
  final double size;

  /// Size of icon.
  /// Default: 28
  final double iconSize;

  /// Whether to show cursor glow effect.
  /// Default: true
  final bool showCursorGlow;

  /// Border radius of button.
  /// Default: 40
  final double borderRadius;

  /// Creates a copy of this config with given fields replaced.
  FluidTrailingActionButtonConfig copyWith({
    IconData? icon,
    IconData Function(int)? iconBuilder,
    TrailingActionTapCallback? onTap,
    Color? backgroundColor,
    Color? iconColor,
    Color? borderColor,
    double? borderColorAlpha,
    Color? shadowColor,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    double? size,
    double? iconSize,
    bool? showCursorGlow,
    double? borderRadius,
  }) {
    return FluidTrailingActionButtonConfig(
      icon: icon ?? this.icon,
      iconBuilder: iconBuilder ?? this.iconBuilder,
      onTap: onTap ?? this.onTap,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconColor: iconColor ?? this.iconColor,
      borderColor: borderColor ?? this.borderColor,
      borderColorAlpha: borderColorAlpha ?? this.borderColorAlpha,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowSpreadRadius: shadowSpreadRadius ?? this.shadowSpreadRadius,
      size: size ?? this.size,
      iconSize: iconSize ?? this.iconSize,
      showCursorGlow: showCursorGlow ?? this.showCursorGlow,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

/// A trailing action button with slide and scale animations.
///
/// Used as an optional trailing widget in [FluidBottomNavBar]. Features:
/// - Slide animation when tab changes
/// - Elastic tap gesture
/// - Dynamic icon based on current index or single icon
/// - Optional hero animations
///
/// ## Example
///
/// ```dart
/// FluidTrailingActionButton(
///   currentIndex: 0,
///   config: FluidTrailingActionButtonConfig(
///     icon: Icons.add,
///     onTap: (index) => print('Tapped on tab $index'),
///   ),
/// )
/// ```
class FluidTrailingActionButton extends StatefulWidget {
  const FluidTrailingActionButton({
    super.key,
    required this.currentIndex,
    required this.config,
  });

  /// Current navigation index.
  final int currentIndex;

  /// Configuration for styling and callbacks.
  final FluidTrailingActionButtonConfig config;

  @override
  State<FluidTrailingActionButton> createState() =>
      _FluidTrailingActionButtonState();
}

class _FluidTrailingActionButtonState extends State<FluidTrailingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  int? _previousIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
    _previousIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(FluidTrailingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentIndex = widget.currentIndex;
    if (_previousIndex != currentIndex && _previousIndex != null) {
      _controller.forward(from: 0.0);
      _previousIndex = currentIndex;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isGoingForward {
    if (_previousIndex == null) return false;
    return widget.currentIndex > _previousIndex!;
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    final backgroundColor = config.backgroundColor ?? const Color(0xFF4CAF50);
    final iconColor = config.iconColor ?? Colors.white;
    final borderColor = config.borderColor ?? backgroundColor;
    final shadowColor = config.shadowColor ?? backgroundColor;

    // Get icon - prefer iconBuilder, fall back to single icon
    final icon = config.iconBuilder != null
        ? config.iconBuilder!(widget.currentIndex)
        : config.icon;

    if (icon == null) {
      return const SizedBox.shrink();
    }

    return HeroMode(
      enabled: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(config.borderRadius),
        child: ElasticTapGesture(
          showCursorGlow: config.showCursorGlow,
          onTap: () => config.onTap(widget.currentIndex),
          child: Container(
            width: config.size,
            height: config.size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor.withValues(alpha: config.borderColorAlpha),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha: config.borderColorAlpha),
                  blurRadius: config.shadowBlurRadius,
                  spreadRadius: config.shadowSpreadRadius,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                final slideValue = (1 - _slideAnimation.value) * 0.5;
                final offset = Offset(
                  _isGoingForward ? -slideValue : slideValue,
                  0,
                );

                return FractionalTranslation(
                  translation: offset,
                  child: Opacity(opacity: _slideAnimation.value, child: child),
                );
              },
              child: Icon(
                key: ValueKey<int>(widget.currentIndex),
                icon,
                size: config.iconSize,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
