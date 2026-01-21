import 'package:flutter/material.dart';

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
///
/// ## Example
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
class FluidNavItem extends StatelessWidget {
  const FluidNavItem({
    super.key,
    required this.icon,
    this.label,
    required this.isActive,
    required this.onTap,
    required this.theme,
    this.showCursorGlow = true,
    this.padding,
    this.borderRadius,
  });

  /// Icon to display for this navigation item.
  final IconData icon;

  /// Label text to display below the icon.
  final String? label;

  /// Whether this navigation item is currently active/selected.
  final bool isActive;

  /// Called when the item is tapped.
  final VoidCallback onTap;

  /// Theme configuration for styling.
  final ResolvedFluidBottomNavBarTheme theme;

  /// Whether to show cursor glow effect on tap (default: true).
  final bool showCursorGlow;

  /// Optional padding to override default theme padding.
  final EdgeInsetsGeometry? padding;

  /// Optional border radius to override default theme radius.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final activeColor = isActive
        ? theme.iconActiveColor
        : theme.iconInactiveColor;
    final activeLabelColor = isActive
        ? theme.labelActiveColor
        : theme.labelInactiveColor;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 4),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(25),
        child: ElasticTapGesture(
          showCursorGlow: showCursorGlow,
          onTap: onTap,
          child: AnimatedPadding(
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
                  SizedBox(height: 6),
                  AnimatedScale(
                    scale: isActive ? 1.3 : 1.0,
                    duration: theme.scaleAnimationDuration,
                    curve: Curves.elasticOut,
                    child: Icon(icon, size: theme.iconSize, color: activeColor),
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
        ),
      ),
    );
  }
}
