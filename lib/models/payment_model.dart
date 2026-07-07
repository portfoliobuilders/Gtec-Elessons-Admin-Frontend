/// Payments & Leads table row.
class PaymentModel {
  const PaymentModel({
    required this.monogram,
    required this.name,
    required this.phone,
    required this.email,
    required this.source,
    required this.course,
    required this.courseMuted,
    required this.date,
    required this.dateMuted,
    required this.amount,
    required this.amountColorKey,
    required this.method,
    required this.status,
  });

  final String monogram;
  final String name;
  final String phone;
  final String email;
  final String source;
  final String course;
  final bool courseMuted;
  final String date;
  final bool dateMuted;
  final String amount;
  final PaymentAmountColor amountColorKey;
  final String method;
  final String status; // PAID / LEAD / TRIAL / FAILED
}

enum PaymentAmountColor { ink, muted, red }
