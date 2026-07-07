/// Simple KPI tile value (dashboard / teacher / payments / growth).
class KpiModel {
  const KpiModel({
    required this.caption,
    required this.value,
    this.delta,
    this.deltaPositive = true,
    this.iconPaths,
    this.accent = false,
    this.valueSuffix,
  });

  final String caption;
  final String value;
  final String? delta;
  final bool deltaPositive;
  final String? iconPaths;

  /// true → red icon tile / red value (e.g. drop-off, failed).
  final bool accent;

  /// Grey suffix rendered after the value (e.g. `· 22%`).
  final String? valueSuffix;
}
