import '../curriculum/regional_pricing_section.dart' show currencySymbolFor;

/// Converts a minor-unit integer (the order endpoints still return
/// `*Cents` fields — confirmed live against `GET /admin/orders`, unlike
/// Phase 5's regional pricing, which now returns a canonical `amount`) into
/// a display string, e.g. `4720000` → `INR 47,200.00`. Display only — this
/// phase never sends money back to the backend, and never converts between
/// currencies; an order's recorded amount/currency is historical and final.
String formatOrderMoney(int cents, String currency) {
  final amount = (cents / 100).toStringAsFixed(2);
  final parts = amount.split('.');
  return '${currencySymbolFor(currency)} ${_withThousandsSeparators(parts[0])}.${parts[1]}';
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
