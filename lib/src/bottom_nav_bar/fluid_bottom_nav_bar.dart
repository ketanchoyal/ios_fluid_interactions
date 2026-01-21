import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ios_fluid_interactions/ios_fluid_interactions.dart';

import '../glow.dart';
import 'fluid_nav_destination.dart';
import 'fluid_nav_item.dart';
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

/// A fluid, animated bottom navigation bar with iOS-style interactions.
///
/// Features:
/// - Shrink/expand animation controlled by [shrinkNotifier]
/// - Elastic tap animations on navigation items
/// - Optional floating widget (shown conditionally on specific tab)
/// - Optional trailing action button with slide animations
/// - Glass-morphism style with backdrop blur
/// - Customizable theme via [FluidBottomNavBarTheme]
/// - Support for custom nav item widgets via [itemBuilder]
///
/// ## Example (simple)
///
/// ```dart
/// FluidBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (index) => setState(() => _currentIndex = index),
///   shrinkNotifier: _isNavBarShrunk,
///   destinations: [
///     FluidNavDestination(icon: Icons.home, label: 'Home'),
///     FluidNavDestination(icon: Icons.flag, label: 'Goals'),
///     FluidNavDestination(icon: Icons.history, label: 'History'),
///   ],
/// )
/// ```
///
/// ## Example (with theme)
///
/// ```dart
/// FluidBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (index) => setState(() => _currentIndex = index),
///   shrinkNotifier: _isNavBarShrunk,
///   destinations: [...],
///   theme: FluidBottomNavBarTheme.light(
///     iconActiveColor: Colors.blue,
///   ),
/// )
/// ```
///
/// ## Example (custom items)
///
/// ```dart
/// FluidBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (index) => setState(() => _currentIndex = index),
///   shrinkNotifier: _isNavBarShrunk,
///   destinations: [...],
///   itemBuilder: (context, index, destination, isActive) {
///     return MyCustomNavItem(...);
///   },
/// )
/// ```
class FluidBottomNavBar extends StatelessWidget {
  const FluidBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.shrinkNotifier,
    required this.destinations,
    this.theme,
    this.floatingWidget,
    this.floatingWidgetTabIndex,
    this.showFloatingWhenShrunk = true,
    this.trailingButtonConfig,
    this.trailingWidget,
    this.enableGlow = true,
    this.itemBuilder,
  });

  /// Currently selected navigation item index.
  final int currentIndex;

  /// Called when a navigation item is tapped.
  final NavTapCallback onTap;

  /// Notifier that controls shrink/expand state.
  final ValueNotifier<bool> shrinkNotifier;

  /// List of navigation destinations.
  /// If [itemBuilder] is provided, this is still required for icon/label data.
  final List<FluidNavDestination> destinations;

  /// Theme configuration for styling.
  /// If null, uses default values.
  final FluidBottomNavBarTheme? theme;

  /// Optional widget to display floating in nav bar.
  /// Shown conditionally based on [floatingWidgetTabIndex] and [showFloatingWhenShrunk].
  final Widget? floatingWidget;

  /// Index of tab where floating widget should be shown.
  /// If null, floating widget is shown on all tabs.
  final int? floatingWidgetTabIndex;

  /// Whether to show floating widget when nav bar is shrunk.
  /// If false, shows when expanded.
  final bool showFloatingWhenShrunk;

  /// Configuration for built-in trailing action button.
  final FluidTrailingActionButtonConfig? trailingButtonConfig;

  /// Custom trailing widget (alternative to [trailingButtonConfig]).
  final Widget? trailingWidget;

  /// Whether to enable glow effect.
  final bool enableGlow;

  /// Optional builder for creating custom navigation item widgets.
  /// If provided, this is called instead of using built-in [FluidNavItem].
  final NavItemBuilder? itemBuilder;

  @override
  Widget build(BuildContext buildContext) {
    final resolvedTheme =
        theme?.resolve() ?? FluidBottomNavBarTheme().resolve();

    return ValueListenableBuilder<bool>(
      valueListenable: shrinkNotifier,
      builder: (context, isShrunk, child) {
        final showFloating = _shouldShowFloatingWidget();
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItems(context, isShrunk, resolvedTheme),
            if (floatingWidget != null)
              Flexible(
                child: AnimatedOpacity(
                  duration: resolvedTheme.opacityAnimationDuration,
                  opacity: showFloating ? 1.0 : 0.0,
                  child: showFloating
                      ? _buildFloatingWidget()
                      : const SizedBox.shrink(),
                ),
              ),
            if (trailingWidget != null)
              trailingWidget!
            else if (trailingButtonConfig != null)
              FluidTrailingActionButton(
                currentIndex: currentIndex,
                config: trailingButtonConfig!,
              ),
          ],
        );
      },
    );
  }

  /// Builds navigation items row.
  Widget _buildNavItems(
    BuildContext context,
    bool isShrunk,
    ResolvedFluidBottomNavBarTheme resolvedTheme,
  ) {
    return ElasticTapGesture(
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(resolvedTheme.borderRadius),
        ),
        child: Glow(
          enabled: enableGlow,
          child: Container(
            decoration: BoxDecoration(
              color: resolvedTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: resolvedTheme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: resolvedTheme.shadowBlurRadius,
                  spreadRadius: resolvedTheme.shadowSpreadRadius,
                ),
              ],
              borderRadius: BorderRadius.all(
                Radius.circular(resolvedTheme.borderRadius),
              ),
              border: Border.all(
                color: resolvedTheme.borderColor.withValues(
                  alpha: resolvedTheme.borderAlpha,
                ),
                width: 0.1,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int i = 0; i < destinations.length; i++)
                      _buildNavItem(
                        context: context,
                        index: i,
                        destination: destinations[i],
                        isShrunk: isShrunk,
                        resolvedTheme: resolvedTheme,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an individual navigation item with visibility animation.
  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required FluidNavDestination destination,
    required bool isShrunk,
    required ResolvedFluidBottomNavBarTheme resolvedTheme,
  }) {
    final isSelected = currentIndex == index;
    final isVisible = isSelected || !isShrunk;

    // Choose icon based on state
    final displayIcon = isSelected && destination.filledIcon != null
        ? destination.filledIcon!
        : destination.icon;

    return ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.centerLeft,
        duration: resolvedTheme.shrinkAnimationDuration,
        curve: Curves.easeOutCubic,
        widthFactor: isVisible ? 1.0 : 0.0,
        heightFactor: 1.0,
        child: AnimatedOpacity(
          duration: resolvedTheme.opacityAnimationDuration,
          opacity: isVisible ? 1.0 : 0.0,
          child: itemBuilder != null
              ? itemBuilder!(context, index, destination, isSelected)
              : FluidNavItem(
                  icon: displayIcon,
                  label: destination.label,
                  isActive: isSelected,
                  onTap: () => _onTap(index, isShrunk),
                  theme: resolvedTheme,
                ),
        ),
      ),
    );
  }

  /// Builds floating widget.
  Widget _buildFloatingWidget() {
    if (floatingWidget == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: floatingWidget!,
    );
  }

  /// Determines whether to show floating widget based on conditions.
  bool _shouldShowFloatingWidget() {
    if (floatingWidget == null) return false;

    final isOnCorrectTab =
        floatingWidgetTabIndex == null ||
        currentIndex == floatingWidgetTabIndex;

    return isOnCorrectTab && showFloatingWhenShrunk == shrinkNotifier.value;
  }

  /// Handles navigation item tap.
  void _onTap(int index, bool isShrunk) {
    // If shrunk, just expand
    if (isShrunk) {
      shrinkNotifier.value = false;
      return;
    }

    // If tapping current item, shrink it
    if (index == currentIndex && !isShrunk) {
      shrinkNotifier.value = true;
      return;
    }

    // Otherwise, navigate to the tapped item
    onTap(index);
  }
}
