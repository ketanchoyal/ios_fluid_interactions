import 'package:flutter/material.dart';
import 'package:ios_fluid_interactions/ios_fluid_interactions.dart';
import 'package:ios_fluid_interactions/src/glow_painter.dart';

import '../elastic_tap_gesture.dart';
import 'fluid_nav_theme.dart';

/// A navigation item widget with elastic tap animations.
///
/// Used as a child of [FluidBottomNavBar] to represent individual navigation
/// destinations. Features:
/// - Elastic tap gesture with iOS-style bouncy animation
/// - Scale animation when active
/// - Icon and label with conditional visibility
/// - Customizable colors via [FluidBottomNavBarTheme]
/// - Optional highlight-while-moving gesture
///
/// ## Example (with ElasticTapGesture)
///
/// ```dart
/// FluidNavItem(
///   icon: Icons.home,
///   label: 'Home',
///   isActive: true,
///   onTap: () => print('Home tapped'),
///   theme: theme,
/// )
/// ```
///
/// ## Example (with highlight gesture)
///
/// ```dart
/// FluidBottomNavBar(
///   useHighlightGesture: true,  // Enable highlight-while-moving
///   destinations: [...],
/// )
/// ```
class FluidNavItem extends StatelessWidget {
  const FluidNavItem({
    super.key,
    required this.icon,
    this.label,
    required this.isActive,
    required this.isHighlighted,
    required this.theme,
    this.showCursorGlow = true,
    this.padding,
    this.borderRadius,
    this.position,
    this.glowColor,
  });

  /// Current pointer position for glow center.
  final Offset? position;

  /// Icon to display for this navigation item.
  final IconData icon;

  /// Label text to display below the icon.
  final String? label;

  /// Whether this navigation item is currently active/selected.
  final bool isActive;

  /// Whether this navigation item is currently highlighted (for highlight gesture).
  final bool isHighlighted;

  /// Theme configuration for styling.
  final ResolvedFluidBottomNavBarTheme theme;

  /// Whether to show cursor glow effect on tap (default: true).
  final bool showCursorGlow;

  /// Optional padding to override default theme padding.
  final EdgeInsetsGeometry? padding;

  /// Optional border radius to override default theme radius.
  final BorderRadius? borderRadius;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final activeColor = isActive
        ? theme.iconActiveColor
        : theme.iconInactiveColor;
    final activeLabelColor = isActive
        ? theme.labelActiveColor
        : theme.labelInactiveColor;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(25),
      child: ElasticTapGesture(
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 2),
          child: Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              if (position != null && isHighlighted && showCursorGlow)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: GlowPainter(
                        position!,
                        glowColor ?? Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),

              AnimatedPadding(
                duration: theme.scaleAnimationDuration,
                padding: EdgeInsets.symmetric(
                  vertical: isActive ? 2 : 4,
                  horizontal: 2.5,
                ),
                child: SizedBox(
                  width: theme.navItemWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 4),
                      AnimatedScale(
                        scale: isActive ? 1.3 : 1.0,
                        duration: theme.scaleAnimationDuration,
                        curve: Curves.elasticOut,
                        child: Icon(
                          icon,
                          size: theme.iconSize,
                          color: activeColor,
                        ),
                      ),
                      if (label != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: AnimatedScale(
                            scale: isActive ? 1.1 : 1.0,
                            duration: theme.scaleAnimationDuration,
                            curve: Curves.elasticOut,
                            child: Text(
                              label!,
                              style: theme.labelTextStyle.copyWith(
                                letterSpacing: 0.2,
                                height: 1.3,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: activeLabelColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
