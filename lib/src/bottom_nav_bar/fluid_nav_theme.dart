import 'package:flutter/material.dart';

/// Theme configuration for [FluidBottomNavBar] components.
///
/// All parameters have sensible defaults based on the original implementation.
/// You can customize individual values as needed.
///
/// ## Example
///
/// ```dart
/// FluidBottomNavBarTheme(
///   iconActiveColor: Colors.blue,
///   backgroundColor: Colors.grey[100],
/// )
/// ```
class FluidBottomNavBarTheme {
  const FluidBottomNavBarTheme({
    this.backgroundColor,
    this.borderColor,
    this.iconActiveColor,
    this.iconInactiveColor,
    this.labelActiveColor,
    this.labelInactiveColor,
    this.shadowColor,
    this.labelTextStyle,
    this.borderRadius,
    this.navItemWidth,
    this.iconSize,
    this.shadowBlurRadius,
    this.shadowSpreadRadius,
    this.glowRadius,
    this.shrinkAnimationDuration,
    this.scaleAnimationDuration,
    this.opacityAnimationDuration,
  });

  // ==========================================================================
  // COLORS - with sensible defaults
  // ==========================================================================

  /// Background color of the navigation bar container.
  /// Default: semi-transparent green (#4CAF50 with 10% opacity)
  final Color? backgroundColor;

  /// Border color (usually white with transparency).
  /// Default: white
  final Color? borderColor;

  /// Icon color when navigation item is active.
  /// Default: green (#4CAF50)
  final Color? iconActiveColor;

  /// Icon color when navigation item is inactive.
  /// Default: grey
  final Color? iconInactiveColor;

  /// Label text color when navigation item is active.
  /// Default: green (#4CAF50)
  final Color? labelActiveColor;

  /// Label text color when navigation item is inactive.
  /// Default: grey
  final Color? labelInactiveColor;

  /// Color of the shadow/glow effect.
  /// Default: white
  final Color? shadowColor;

  // ==========================================================================
  // TYPOGRAPHY - with sensible defaults
  // ==========================================================================

  /// Text style for navigation item labels.
  /// Default: 12px, letter spacing 0.2, height 1.3
  final TextStyle? labelTextStyle;

  // ==========================================================================
  // DIMENSIONS - with sensible defaults
  // ==========================================================================

  /// Border radius for the navigation bar container.
  /// Default: 38
  final double? borderRadius;

  /// Width of each navigation item.
  /// Default: 64
  final double? navItemWidth;

  /// Size of navigation icons.
  /// Default: 24
  final double? iconSize;

  // ==========================================================================
  // EFFECTS - with sensible defaults
  // ==========================================================================

  /// Blur radius for shadow effect.
  /// Default: 20
  final double? shadowBlurRadius;

  /// Spread radius for shadow effect.
  /// Default: 10
  final double? shadowSpreadRadius;

  /// Radius for cursor glow effect.
  /// Default: 250.0
  final double? glowRadius;

  // ==========================================================================
  // ANIMATION DURATIONS - with sensible defaults
  // ==========================================================================

  /// Duration for shrink/expand animation.
  /// Default: 300ms
  final Duration? shrinkAnimationDuration;

  /// Duration for scale animation.
  /// Default: 300ms
  final Duration? scaleAnimationDuration;

  /// Duration for opacity animation.
  /// Default: 200ms
  final Duration? opacityAnimationDuration;

  // ==========================================================================
  // HELPERS - Get value with default
  // ==========================================================================

  Color _getBackgroundColor() => backgroundColor ?? const Color(0x1A4CAF50);
  Color _getBorderColor() => borderColor ?? Colors.white;
  Color _getIconActiveColor() => iconActiveColor ?? const Color(0xFF4CAF50);
  Color _getIconInactiveColor() => iconInactiveColor ?? Colors.grey.shade600;
  Color _getLabelActiveColor() => labelActiveColor ?? const Color(0xFF4CAF50);
  Color _getLabelInactiveColor() => labelInactiveColor ?? Colors.grey.shade600;
  Color _getShadowColor() => shadowColor ?? Colors.black;
  TextStyle _getLabelTextStyle() =>
      labelTextStyle ??
      const TextStyle(fontSize: 10, letterSpacing: 0.2, height: 1.3);
  double _getBorderRadius() => borderRadius ?? 45;
  double _getNavItemWidth() => navItemWidth ?? 64;
  double _getIconSize() => iconSize ?? 20;
  double _getShadowBlurRadius() => shadowBlurRadius ?? 20;
  double _getShadowSpreadRadius() => shadowSpreadRadius ?? 10;
  double _getGlowRadius() => glowRadius ?? 250.0;
  Duration _getShrinkAnimationDuration() =>
      shrinkAnimationDuration ?? const Duration(milliseconds: 300);
  Duration _getScaleAnimationDuration() =>
      scaleAnimationDuration ?? const Duration(milliseconds: 300);
  Duration _getOpacityAnimationDuration() =>
      opacityAnimationDuration ?? const Duration(milliseconds: 200);

  // ==========================================================================
  // FACTORY CONSTRUCTORS - For convenience
  // ==========================================================================

  /// Creates a light theme (default values).
  factory FluidBottomNavBarTheme.light({
    Color? backgroundColor,
    Color? iconActiveColor,
    Color? iconInactiveColor,
    Color? labelActiveColor,
    Color? labelInactiveColor,
  }) {
    return FluidBottomNavBarTheme(
      backgroundColor: backgroundColor,
      iconActiveColor: iconActiveColor,
      iconInactiveColor: iconInactiveColor,
      labelActiveColor: labelActiveColor,
      labelInactiveColor: labelInactiveColor,
    );
  }

  /// Creates a dark theme suitable for dark mode apps.
  factory FluidBottomNavBarTheme.dark({
    Color? backgroundColor,
    Color? iconActiveColor,
    Color? iconInactiveColor,
    Color? labelActiveColor,
    Color? labelInactiveColor,
  }) {
    return FluidBottomNavBarTheme(
      backgroundColor: backgroundColor ?? const Color(0x1A66BB6A),
      iconActiveColor: iconActiveColor ?? const Color(0xFF66BB6A),
      iconInactiveColor: iconInactiveColor ?? Colors.grey.shade400,
      labelActiveColor: labelActiveColor ?? const Color(0xFF66BB6A),
      labelInactiveColor: labelInactiveColor ?? Colors.grey.shade400,
    );
  }

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  /// Creates a copy of this theme with the given fields replaced.
  FluidBottomNavBarTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? iconActiveColor,
    Color? iconInactiveColor,
    Color? labelActiveColor,
    Color? labelInactiveColor,
    Color? shadowColor,
    TextStyle? labelTextStyle,
    double? borderRadius,
    double? navItemWidth,
    double? iconSize,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    double? glowRadius,
    Duration? shrinkAnimationDuration,
    Duration? scaleAnimationDuration,
    Duration? opacityAnimationDuration,
  }) {
    return FluidBottomNavBarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      iconActiveColor: iconActiveColor ?? this.iconActiveColor,
      iconInactiveColor: iconInactiveColor ?? this.iconInactiveColor,
      labelActiveColor: labelActiveColor ?? this.labelActiveColor,
      labelInactiveColor: labelInactiveColor ?? this.labelInactiveColor,
      shadowColor: shadowColor ?? this.shadowColor,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      navItemWidth: navItemWidth ?? this.navItemWidth,
      iconSize: iconSize ?? this.iconSize,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowSpreadRadius: shadowSpreadRadius ?? this.shadowSpreadRadius,
      glowRadius: glowRadius ?? this.glowRadius,
      shrinkAnimationDuration:
          shrinkAnimationDuration ?? this.shrinkAnimationDuration,
      scaleAnimationDuration:
          scaleAnimationDuration ?? this.scaleAnimationDuration,
      opacityAnimationDuration:
          opacityAnimationDuration ?? this.opacityAnimationDuration,
    );
  }

  // ==========================================================================
  // INTERNAL - Create a resolved theme (all values set)
  // ==========================================================================

  /// Resolves all optional values to their defaults.
  /// Used internally by [FluidBottomNavBar].
  ResolvedFluidBottomNavBarTheme resolve() {
    return ResolvedFluidBottomNavBarTheme(
      backgroundColor: _getBackgroundColor(),
      borderColor: _getBorderColor(),
      iconActiveColor: _getIconActiveColor(),
      iconInactiveColor: _getIconInactiveColor(),
      labelActiveColor: _getLabelActiveColor(),
      labelInactiveColor: _getLabelInactiveColor(),
      shadowColor: _getShadowColor(),
      labelTextStyle: _getLabelTextStyle(),
      borderRadius: _getBorderRadius(),
      navItemWidth: _getNavItemWidth(),
      iconSize: _getIconSize(),
      shadowBlurRadius: _getShadowBlurRadius(),
      shadowSpreadRadius: _getShadowSpreadRadius(),

      glowRadius: _getGlowRadius(),
      shrinkAnimationDuration: _getShrinkAnimationDuration(),
      scaleAnimationDuration: _getScaleAnimationDuration(),
      opacityAnimationDuration: _getOpacityAnimationDuration(),
    );
  }
}

/// Internal resolved theme with all values set.
class ResolvedFluidBottomNavBarTheme {
  const ResolvedFluidBottomNavBarTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconActiveColor,
    required this.iconInactiveColor,
    required this.labelActiveColor,
    required this.labelInactiveColor,
    required this.shadowColor,
    required this.labelTextStyle,
    required this.borderRadius,
    required this.navItemWidth,
    required this.iconSize,
    required this.shadowBlurRadius,
    required this.shadowSpreadRadius,

    required this.glowRadius,
    required this.shrinkAnimationDuration,
    required this.scaleAnimationDuration,
    required this.opacityAnimationDuration,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color iconActiveColor;
  final Color iconInactiveColor;
  final Color labelActiveColor;
  final Color labelInactiveColor;
  final Color shadowColor;
  final TextStyle labelTextStyle;
  final double borderRadius;
  final double navItemWidth;
  final double iconSize;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;

  final double glowRadius;
  final Duration shrinkAnimationDuration;
  final Duration scaleAnimationDuration;
  final Duration opacityAnimationDuration;
}
