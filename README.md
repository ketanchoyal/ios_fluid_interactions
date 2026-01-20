# iOS Fluid Interactions

A Flutter package providing iOS-style fluid, spring-based animations and touch interactions.

## Features

### ElasticTapGesture

A widget that applies elastic spring animations on tap with iOS-style "bouncy" interactions:

- **Gesture detection**: Handles tap, long tap, drag
- **Elastic animation**: Spring physics with 5 animation controllers
- **Cursor glow**: Optional radial glow via `showCursorGlow`
- **Adaptive scaling**: Auto-calculates scale based on widget size
- **Volume preservation**: Jelly effect during drag
- **Extension types**: Type-safe presets for physics parameters

### Glow

Easy-to-use radial glow effect widget that auto-tracks pointer position:

- **Auto-tracking**: Wraps any widget, no manual position tracking needed
- **Simple API**: Just `Glow(enabled: true, child: MyWidget())`
- **Customizable**: Radius, color, and blend mode

### Elastic Types

Type-safe extension types for configuring physics parameters:

- **ElasticDampingIntencity**: Controls bounce behavior (low/medium/high)
- **DragIntensity**: Controls movement during drag (none/low/medium/high)
- **DeformIntensity**: Controls jelly effect (low/medium/high)
- **Scaling**: Controls scale on tap (none/slight/adaptive)

## Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  ios_fluid_interactions:
    path: ../ios_fluid_interactions
```

## Usage

### ElasticTapGesture - Complete solution

```dart
// Basic usage
ElasticTapGesture(
  onTap: () => print('Tapped!'),
  child: MyWidget(),
)

// With cursor glow (iOS-style touch feedback)
ElasticTapGesture(
  onTap: () => print('Tapped!'),
  showCursorGlow: true,
  child: MyWidget(),
)

// With long tap and custom physics using extension types
ElasticTapGesture(
  onTap: () => print('Tapped!'),
  onLongTap: () => print('Long pressed!'),
  scaling: Scaling.adaptive,
  elasticDampingIntencity: ElasticDampingIntencity.high,
  deformIntensity: DeformIntensity.high,
  dragIntensity: DragIntensity.low,
  showCursorGlow: true,
  child: MyWidget(),
)

// Using fixed scale instead of adaptive
ElasticTapGesture(
  onTap: () => print('Tapped!'),
  scaling: Scaling.slight, // Fixed 1.05 scale
  showCursorGlow: true,
  child: MyWidget(),
)
```

### Glow - Standalone glow

```dart
// Easy to use - just wrap your widget
Glow(
  enabled: true,
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
  ),
)

// Custom styling
Glow(
  enabled: true,
  radius: 300.0,  // Larger glow
  color: Colors.blue,  // Blue glow
  blendMode: BlendMode.color,  // Solid color
  child: MyWidget(),
)
```

### Extension Types Reference

```dart
// ElasticDampingIntencity - Controls bounce behavior
ElasticDampingIntencity.low     // 5.0 - More bounce, more oscillation
ElasticDampingIntencity.medium  // 10.0 - Balanced bounce
ElasticDampingIntencity.high    // 20.0 - Less bounce, settles quickly
ElasticDampingIntencity(15.0)   // Custom value

// DragIntensity - Controls movement during drag
DragIntensity.none    // 0.0 - Widget stays in place
DragIntensity.low     // 0.5 - Widget follows finger less
DragIntensity.medium  // 1.0 - Normal movement
DragIntensity.high    // 2.0 - Widget follows finger more

// DeformIntensity - Controls jelly effect
DeformIntensity.low     // 0.5 - Subtle jelly effect
DeformIntensity.medium  // 1.0 - Balanced jelly effect
DeformIntensity.high    // 2.0 - Dramatic jelly effect

// Scaling - Controls scale on tap
Scaling.none          // 1.0 - No scaling
Scaling.slight         // 1.05 - Small scale
Scaling.adaptive       // Auto-calculate based on widget size
Scaling(1.2)          // Custom scale value
```

## Parameters

### ElasticTapGesture

| Parameter | Default | Description |
|-----------|---------|-------------|
| `child` | required | Widget to display and animate |
| `onTap` | null | Called when tap is released inside widget |
| `onLongTap` | null | Called when tap is held for 500ms |
| `onTapDown` | null | Called when pointer goes down |
| `onTapUp` | null | Called when pointer goes up |
| `onPointerMove` | null | Called when pointer moves |
| `enabled` | true | Whether elastic behavior is enabled |
| `showCursorGlow` | false | Show radial glow effect under cursor |
| `scaling` | `Scaling.adaptive` | Scale behavior (see extension types) |
| `scaleGrowthPixels` | 10.0 | Pixel growth for adaptive scaling |
| `elasticDampingIntencity` | `ElasticDampingIntencity.medium` | Damping for elastic animation |
| `deformIntensity` | `DeformIntensity.medium` | Deformation responsiveness during drag |
| `dragIntensity` | `DragIntensity.medium` | Drag movement intensity |

### Glow

| Parameter | Default | Description |
|-----------|---------|-------------|
| `child` | required | Widget to display |
| `enabled` | true | Whether glow effect is enabled |
| `color` | Colors.white | Color of glow |
| `radius` | 250.0 | Radius of glow effect |
| `blendMode` | BlendMode.overlay | Blend mode for glow |

## How It Works

### ElasticTapGesture Animation

The widget uses 5 independent animation controllers for smooth, natural motion:

1. **Scale** - Overall size (1.0 = normal size)
2. **DeformX** - Horizontal stretch (1.0 = normal, >1 = stretched, <1 = compressed)
3. **DeformY** - Vertical stretch (1.0 = normal)
4. **ShiftX** - Horizontal offset in pixels (0.0 = no offset)
5. **ShiftY** - Vertical offset in pixels (0.0 = no offset)

All controllers are unbounded (can exceed 0-1 range) to allow spring overshoot for natural bounce effects.

### Volume Preservation (Jelly Effect)

When dragging, the widget maintains visual "volume preservation":

- Moving horizontally → stretches X, compresses Y
- Moving vertically → stretches Y, compresses X
- Moving diagonally → balanced (no deformation)

This creates the characteristic "jelly" or "rubber" feel.

### Spring Physics

The widget uses three different spring configurations:

1. **Press spring** - Quick, snappy (mass: 1.2, stiffness: 500, damping: 15)
2. **Release spring** - Smooth, controlled (mass: 1.0, stiffness: 180, damping: 24)
3. **Elastic spring** - Bouncy, user-configurable damping (mass: 1.0, stiffness: 250, damping: customizable)

### Adaptive Scaling

When `Scaling.adaptive`, the widget calculates scale to produce consistent pixel growth across different widget sizes:

Formula: `scale = 1.0 + (scaleGrowthPixels / diagonal)`

Examples with `scaleGrowthPixels = 10`:
- 50x50 widget → scale ≈ 1.14
- 100x100 widget → scale ≈ 1.07
- 200x200 widget → scale ≈ 1.04

## Architecture

```
ElasticTapGesture (gesture detection)
  ├── Spring animations (5 controllers)
  │     ├── Scale animation
  │     ├── DeformX/Y animation (jelly effect)
  │     └── ShiftX/Y animation (drag movement)
  └── Optional Glow (radial highlight)
        └── CustomPaint
```

**Independent use:**
- `Glow` - Glow effect only, auto-tracks pointer

## License

MIT License - see LICENSE file for details
