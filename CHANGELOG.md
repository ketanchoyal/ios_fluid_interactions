# Changelog

All notable changes to the iOS Fluid Interactions package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - 2026-01-27

### Enhanced
- Improved haptic feedback on Android platform with fallback to `vibrate()` for better compatibility
- Added haptic feedback to `ElasticTapGesture` for more responsive user interaction
- Enhanced haptic feedback consistency across gesture handlers

### Fixed
- Updated `TrailingActionTapCallback` to include `BuildContext` parameter for better context access

## [0.4.0] - 2026-01-21

### Enhanced
- Refactored `FluidNavDestination` API to use `Widget` instead of `IconData`
  - Changed `icon` parameter to accept any Widget (not just IconData)
  - Renamed `filledIcon` to `activeIcon` for clarity
  - Now supports custom widgets for both inactive and active states
  - Enables greater flexibility for navigation icon designs
- Updated `FluidNavItem` to work with widget-based icons
- Updated example and documentation with new API usage

## [0.3.0] - 2026-01-21

### Enhanced
- Added customizable radius parameter to `Glow` widget and `GlowPainter`
- Added cursor glow effect to `FluidBottomNavBar` for enhanced visual feedback
- Improved glow clipping across all components for cleaner rendering
- Added matrix-based transformations to nav items for smoother animations

## [0.2.0] - 2026-01-21

### Fixed
- Updated screenshot URLs in README to use GitHub raw links for proper display on pub.dev

### Documentation
- Added screenshots section with demo images

## [0.1.0] - 2026-01-21

### Added
- Initial release of iOS Fluid Interactions package
- `FluidBottomNavBar` - iOS-style bottom navigation with elastic drag interactions
- `ElasticTapGesture` - Widget with spring-based physics and elastic animations
- `Glow` - Radial glow effect widget with auto-tracking
- `FluidNavDestination` - Navigation item widget for bottom nav
- `FluidTrailingActionButton` - Floating action button with slide animations
- `FluidBottomNavBarTheme` - Theme configuration for bottom navigation
- `ElasticTypes` - Type-safe extension types for physics parameters:
  - `ElasticDampingIntencity` - Controls bounce behavior
  - `DragIntensity` - Controls movement during drag
  - `DeformIntensity` - Controls jelly effect
  - `Scaling` - Controls scale on tap

### Features
- Elastic drag interactions with jelly effect
- Cursor glow tracking for iOS-style touch feedback
- Shrink-to-select behavior on bottom navigation
- 5 independent animation controllers for smooth motion
- Volume preservation during drag (jelly effect)
- Spring physics with configurable parameters
- Adaptive scaling based on widget size
- Custom theme support for all components

### Documentation
- Comprehensive README with usage examples
- Parameter documentation for all public APIs
- Architecture diagrams and explanations
