/// Pricing Manager table row.
class PricingItemModel {
  const PricingItemModel({
    required this.code,
    required this.name,
    required this.type,
    required this.inr,
    required this.aed,
    required this.usd,
    required this.isLive,
    this.usdOverridden = false,
  });

  final String code;
  final String name;
  final String type;
  final String inr;
  final String aed;
  final String usd;
  final bool isLive;

  /// Manual FX override — rendered with a navy 2px border + red dot.
  final bool usdOverridden;
}
