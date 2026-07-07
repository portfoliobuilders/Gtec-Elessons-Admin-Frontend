import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Payments & Leads — KPIs + filterable ledger.
class PaymentsController extends ChangeNotifier {
  final List<KpiModel> kpis = const [
    KpiModel(caption: 'Total leads', value: '2,840'),
    KpiModel(caption: 'Converted', value: '612', valueSuffix: '· 22%'),
    KpiModel(caption: 'Revenue · month', value: '₹48.2L'),
    KpiModel(caption: 'Failed / pending', value: '38', accent: true),
  ];

  final List<String> filters = const ['All', 'Paid', 'Lead', 'Trial', 'Failed'];
  int activeFilter = 0;

  final List<PaymentModel> rows = const [
    PaymentModel(
        monogram: 'AS',
        name: 'Aarav Sharma',
        phone: '+91 98765 43210',
        email: 'aarav.s@gmail.com',
        source: 'App',
        course: 'Science · Live+Rec',
        courseMuted: false,
        date: '22 Jun 2026',
        dateMuted: false,
        amount: '₹4,245',
        amountColorKey: PaymentAmountColor.ink,
        method: 'UPI · GPay',
        status: 'PAID'),
    PaymentModel(
        monogram: 'DK',
        name: 'Diya Krishnan',
        phone: '+91 90040 11220',
        email: 'diya.k@gmail.com',
        source: 'Web',
        course: 'Full Year · CBSE 10',
        courseMuted: false,
        date: '19 Jun 2026',
        dateMuted: false,
        amount: '₹11,999',
        amountColorKey: PaymentAmountColor.ink,
        method: 'Card · Visa',
        status: 'PAID'),
    PaymentModel(
        monogram: 'IR',
        name: 'Ishaan R.',
        phone: '+971 50 661 2200',
        email: 'ishaan@outlook.com',
        source: 'Web',
        course: 'Maths — in cart',
        courseMuted: true,
        date: '—',
        dateMuted: true,
        amount: r'$42',
        amountColorKey: PaymentAmountColor.muted,
        method: '—',
        status: 'LEAD'),
    PaymentModel(
        monogram: 'MN',
        name: 'Meera Nair',
        phone: '+91 99461 55220',
        email: 'meera.n@gmail.com',
        source: 'App',
        course: 'Free trial · Science',
        courseMuted: false,
        date: '—',
        dateMuted: true,
        amount: '—',
        amountColorKey: PaymentAmountColor.muted,
        method: '',
        status: 'TRIAL'),
    PaymentModel(
        monogram: 'RV',
        name: 'Rohan V.',
        phone: '+91 80801 33440',
        email: 'rohan.v@gmail.com',
        source: 'App',
        course: 'Science · Recorded',
        courseMuted: false,
        date: '21 Jun 2026',
        dateMuted: false,
        amount: '₹3,499',
        amountColorKey: PaymentAmountColor.red,
        method: 'UPI · failed',
        status: 'FAILED'),
  ];

  void setFilter(int index) {
    activeFilter = index;
    notifyListeners();
  }
}
