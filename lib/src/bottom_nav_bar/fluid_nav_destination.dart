import 'package:flutter/material.dart';

/// Model representing a navigation destination in [FluidBottomNavBar].
///
/// Combines icon widgets and label into a single model.
/// Use this to define navigation items instead of passing icons and labels separately.
///
/// ## Example
///
/// ```dart
/// final destinations = [
///   FluidNavDestination(
///     icon: Icon(Icons.home),
///     activeIcon: Icon(Icons.home_filled),
///     label: 'Home',
///   ),
///   FluidNavDestination(
///     icon: CustomInactiveWidget(),
///     activeIcon: CustomActiveWidget(),
///     label: 'Custom',
///   ),
///   FluidNavDestination(
///     icon: CustomWidget(), // Used for both states if activeIcon is null
///     label: 'Both',
///   ),
/// ];
/// ```
class FluidNavDestination {
  const FluidNavDestination({this.icon, this.activeIcon, this.label, this.key})
    : assert(
        icon != null || activeIcon != null,
        'At least one of icon or activeIcon must be provided',
      );

  /// Widget to display for inactive state.
  /// Used for both states if [activeIcon] is null.
  final Widget? icon;

  /// Optional widget for active state.
  /// If null, [icon] is used for both states.
  final Widget? activeIcon;

  /// Label text to display below the icon.
  final String? label;

  /// Optional key for identifying this destination.
  final Key? key;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FluidNavDestination &&
          runtimeType == other.runtimeType &&
          icon == other.icon &&
          activeIcon == other.activeIcon &&
          label == other.label;

  @override
  int get hashCode => icon.hashCode ^ activeIcon.hashCode ^ label.hashCode;

  @override
  String toString() {
    return 'FluidNavDestination(icon: $icon, activeIcon: $activeIcon, label: $label)';
  }

  /// Creates a copy of this destination with the given fields replaced.
  FluidNavDestination copyWith({
    Widget? icon,
    Widget? activeIcon,
    String? label,
    Key? key,
  }) {
    return FluidNavDestination(
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      label: label ?? this.label,
      key: key ?? this.key,
    );
  }
}
