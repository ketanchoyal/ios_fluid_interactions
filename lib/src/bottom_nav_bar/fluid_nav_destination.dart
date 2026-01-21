import 'package:flutter/material.dart';

/// Model representing a navigation destination in [FluidBottomNavBar].
///
/// Combines icon, label, and optional filled icon into a single model.
/// Use this to define navigation items instead of passing icons and labels separately.
///
/// ## Example
///
/// ```dart
/// final destinations = [
///   FluidNavDestination(
///     icon: Icons.home,
///     filledIcon: Icons.home_filled,
///     label: 'Home',
///   ),
///   FluidNavDestination(
///     icon: Icons.flag,
///     label: 'Goals',
///   ),
///   FluidNavDestination(
///     icon: Icons.history,
///     label: 'History',
///   ),
/// ];
/// ```
class FluidNavDestination {
  const FluidNavDestination({
    required this.icon,
    required this.label,
    this.filledIcon,
    this.key,
  });

  /// Icon to display for inactive state.
  final IconData icon;

  /// Label text to display below the icon.
  final String label;

  /// Optional icon for active/filled state.
  /// If null, [icon] is used for both states.
  final IconData? filledIcon;

  /// Optional key for identifying this destination.
  final Key? key;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FluidNavDestination &&
          runtimeType == other.runtimeType &&
          icon == other.icon &&
          label == other.label &&
          filledIcon == other.filledIcon;

  @override
  int get hashCode => icon.hashCode ^ label.hashCode ^ filledIcon.hashCode;

  @override
  String toString() {
    return 'FluidNavDestination(icon: $icon, label: $label, filledIcon: $filledIcon)';
  }

  /// Creates a copy of this destination with the given fields replaced.
  FluidNavDestination copyWith({
    IconData? icon,
    String? label,
    IconData? filledIcon,
    Key? key,
  }) {
    return FluidNavDestination(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      filledIcon: filledIcon ?? this.filledIcon,
      key: key ?? this.key,
    );
  }
}
