import '../curriculum/regional_pricing_section.dart' show currencySymbolFor;

/// Canonical (non-cents) currency amount → display string, e.g. `12000` +
/// `INR` → `INR 12,000`. Pricing's `AdminProductPriceModel.amount` is
/// already a normal currency amount (confirmed live in Phase 5 — the
/// backend also returns legacy `amountCents` for backward compatibility,
/// never parsed or used here). Distinct from `order_money.dart`'s
/// `formatOrderMoney`, which divides by 100 — Orders is a different,
/// still-legacy-cents backend contract; Pricing is not.
String formatPricingAmount(num amount, String currency) {
  final isWhole = amount == amount.roundToDouble();
  final text = isWhole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
  final parts = text.split('.');
  final withCommas = _withThousandsSeparators(parts[0]);
  return '${currencySymbolFor(currency)} ${parts.length > 1 ? '$withCommas.${parts[1]}' : withCommas}';
}

String _withThousandsSeparators(String digits) {
  final negative = digits.startsWith('-');
  final clean = negative ? digits.substring(1) : digits;
  final buffer = StringBuffer();
  for (int i = 0; i < clean.length; i++) {
    if (i > 0 && (clean.length - i) % 3 == 0) buffer.write(',');
    buffer.write(clean[i]);
  }
  return negative ? '-${buffer.toString()}' : buffer.toString();
}
