import 'package:flutter/material.dart';
import 'package:ios_fluid_interactions/ios_fluid_interactions.dart';
import 'package:ios_fluid_interactions/src/glow_painter.dart';

/// A navigation item widget with elastic tap animations.
///
/// Used as a child of [FluidBottomNavBar] to represent individual navigation
/// destinations. Features:
/// - Elastic tap gesture with iOS-style bouncy animation
/// - Scale animation when active
/// - Icon/child and label with conditional visibility
/// - Customizable colors via [FluidBottomNavBarTheme]
/// - Optional highlight-while-moving gesture
///
/// ## Example (with ElasticTapGesture)
///
/// ```dart
/// FluidNavItem(
///   icon: Icon(Icons.home),
///   activeIcon: Icon(Icons.home_filled),
///   label: 'Home',
///   isActive: true,
///   theme: theme,
/// )
/// ```
///
/// ## Example (with custom widgets)
///
/// ```dart
/// FluidNavItem(
///   icon: CustomInactiveWidget(),
///   activeIcon: CustomActiveWidget(),
///   label: 'Custom',
///   isActive: true,
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
    this.activeIcon,
    this.label,
    required this.isActive,
    required this.isHighlighted,
    required this.theme,
    this.showCursorGlow = true,

    this.borderRadius,
    this.position,
    this.glowColor,
  });

  /// Current pointer position for glow center.
  final Offset? position;

  /// Widget to display for inactive state.
  /// Used for both states if [activeIcon] is null.
  final Widget icon;

  /// Optional widget for active state.
  /// If null, [icon] is used for both states.
  final Widget? activeIcon;

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

  /// Optional border radius to override default theme radius.
  final BorderRadius? borderRadius;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final activeLabelColor = isActive
        ? theme.labelActiveColor
        : theme.labelInactiveColor;

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: Theme.of(context).iconTheme.copyWith(
          color: isActive ? theme.iconActiveColor : theme.iconInactiveColor,
          size: theme.iconSize,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(25),
        child: ElasticTapGesture(
          child: Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              if (position != null && isHighlighted && showCursorGlow)
                AnimatedPositioned(
                  duration: theme.scaleAnimationDuration,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: GlowPainter(
                        position!,
                        glowColor ?? Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),

              SizedBox(
                width: theme.navItemWidth,
                height: theme.navItemHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isActive ? 1.3 : 1.0,
                      duration: theme.scaleAnimationDuration,
                      curve: Curves.elasticOut,
                      child: isActive ? (activeIcon ?? icon) : icon,
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
            ],
          ),
        ),
      ),
    );
  }
}
