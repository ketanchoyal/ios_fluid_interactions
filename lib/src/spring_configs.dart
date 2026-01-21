import 'package:flutter/physics.dart';
import 'elastic_types.dart';

/// Predefined spring configurations for fluid interactions.
///
/// Spring physics create natural, elastic motion. Each spring is defined by:
/// - **mass**: Affects inertia (higher = slower to start/stop)
/// - **stiffness**: Affects speed (higher = faster animation)
/// - **damping**: Affects bounce (lower = more oscillation)
class FluidSprings {
  FluidSprings._();

  /// Quick, snappy spring for press animation.
  ///
  /// High stiffness (500) = fast response
  /// Low damping (15) = slight bounce
  /// Medium mass (1.2) = natural feel
  static const press = SpringDescription(
    mass: 1.2,
    stiffness: 500,
    damping: 15,
  );

  /// Smooth, controlled spring for release animation.
  ///
  /// Lower stiffness (180) = slower than press
  /// Higher damping (24) = less bounce, settles quickly
  /// Medium mass (1.0) = natural feel
  static const release = SpringDescription(
    mass: 1.0,
    stiffness: 180,
    damping: 24,
  );

  /// Bouncy spring for elastic deformation.
  ///
  /// Damping is user-configurable via [ElasticDampingIntencity].
  /// Lower damping = more jelly-like bounce.
  static SpringDescription elastic(ElasticDampingIntencity intensity) =>
      SpringDescription(mass: 1.0, stiffness: 250, damping: intensity.value);
}
