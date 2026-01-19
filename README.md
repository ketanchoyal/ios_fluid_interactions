# ios_fluid_interactions

iOS-style fluid interactions for Flutter - spring physics, elastic animations, drag-to-select menus, and glow effects.

## Features

### ElasticTapGesture

A widget that applies elastic spring animations on tap with iOS-style "bouncy" interactions:

- **Scale animation**: Quick spring effect when pressed
- **Jelly effect**: Deforms in drag direction with volume preservation
- **Glow effect**: Optional radial glow under cursor
- **Long tap support**: Configurable duration and callback
- **Adaptive scaling**: Auto-calculates scale based on widget size

## Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  ios_fluid_interactions:
    path: packages/ios_fluid_interactions
```

Or for pub.dev (when published):

```yaml
dependencies:
  ios_fluid_interactions: ^0.1.0
```

## Usage

### ElasticTapGesture

```dart
import 'package:ios_fluid_interactions/ios_fluid_interactions.dart';

// Basic usage
ElasticTapGesture(
  onTap: () => print('Tapped!'),
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
    child: Text('Tap Me'),
  ),
)

// With custom parameters
ElasticTapGesture(
  onTap: () => print('Tapped!'),
  onLongTap: () => print('Long pressed!'),
  tapScale: 1.2,              // Scale to 120% when pressed
  adaptiveScaling: false,     // Use fixed scale instead of auto
  elasticDamping: 15.0,       // More bouncy deform animation
  deformIntensity: 1.5,       // More responsive deformation
  dragIntensity: 0.5,         // Less movement during drag
  showCursorGlow: true,       // Enable glow effect
  child: MyButton(),
)
```

## API Reference

### ElasticTapGesture

| Parameter           | Type            | Default  | Description                    |
| ------------------- | --------------- | -------- | ------------------------------ |
| `child`             | `Widget`        | required | Widget to animate              |
| `onTap`             | `VoidCallback?` | `null`   | Called on release (if inside)  |
| `onLongTap`         | `VoidCallback?` | `null`   | Called after `longTapDuration` |
| `tapScale`          | `double`        | `1.1`    | Scale factor when pressed      |
| `longTapDuration`   | `Duration`      | `500ms`  | Delay before `onLongTap`       |
| `adaptiveScaling`   | `bool`          | `true`   | Auto-calculate scale by size   |
| `scaleGrowthPixels` | `double`        | `10.0`   | Pixel growth for adaptive      |
| `elasticDamping`    | `double`        | `10.0`   | Deform bounce (lower = more)   |
| `deformIntensity`   | `double`        | `1.0`    | Jelly responsiveness           |
| `dragIntensity`     | `double`        | `1.0`    | Movement during drag           |
| `showCursorGlow`    | `bool`          | `false`  | Enable radial glow             |

## How It Works

### Spring Physics

All animations use `SpringSimulation` for natural motion:

- **Mass**: Affects inertia (higher = slower start/stop)
- **Stiffness**: Affects speed (higher = faster)
- **Damping**: Affects bounce (lower = more oscillation)

### Volume Preservation

The jelly effect maintains visual "volume":

- Drag horizontal → stretch X, compress Y
- Drag vertical → stretch Y, compress X
- Drag diagonal → balanced (no deformation)

### Drag-to-Select

Menu tracking uses pointer events:

1. **PointerDown**: Detects tapped item, triggers haptic
2. **PointerMove**: Updates highlighted item
3. **PointerUp**: Triggers action, dismisses menu

### Popover Positioning

MenuButton automatically calculates popover position:

- Checks available space above and below button
- Positions popover where more space is available
- Handles edge cases when position unavailable
- Fallbacks to center if needed

## License

MIT License - See LICENSE file for details.
