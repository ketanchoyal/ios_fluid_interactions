extension type const ElasticDampingIntencity(double value) {
  static const low = ElasticDampingIntencity(5.0);
  static const medium = ElasticDampingIntencity(10.0);
  static const high = ElasticDampingIntencity(20.0);
}

extension type const DragIntensity(double value) {
  static const none = DragIntensity(0.0);
  static const low = DragIntensity(0.5);
  static const medium = DragIntensity(1.0);
  static const high = DragIntensity(2.0);
}

extension type const DeformIntensity(double value) {
  static const low = DeformIntensity(0.5);
  static const medium = DeformIntensity(1.0);
  static const high = DeformIntensity(2.0);
}

extension type const Scaling(double value) {
  static const none = Scaling(1.0);
  static const slight = Scaling(1.05);

  /// Auto-calculate scale based on widget size.
  ///
  /// When true, smaller widgets scale more than larger ones,
  /// creating consistent pixel growth across all sizes.
  ///
  /// Formula: scale = 1.0 + (scaleGrowthPixels / diagonal)
  ///
  /// Examples with scaleGrowthPixels = 10:
  /// - 50x50 widget → scale ≈ 1.14
  /// - 100x100 widget → scale ≈ 1.07
  /// - 200x200 widget → scale ≈ 1.04
  static const adaptive = Scaling(0);
}
