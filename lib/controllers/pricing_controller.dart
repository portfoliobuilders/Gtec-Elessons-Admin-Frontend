import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Pricing Manager — INR vs GCC table.
class PricingController extends ChangeNotifier {
  int planSegment = 0; // 0 Recorded · 1 Live + Recorded
  final String classFilter = 'Class 10 · CBSE';

  final List<PricingItemModel> items = const [
    PricingItemModel(
        code: 'PKG',
        name: 'Class 10 · Full Year',
        type: 'Bundle',
        inr: '₹11,999',
        aed: 'AED 529',
        usd: r'$ 144',
        isLive: true),
    PricingItemModel(
        code: 'MAT',
        name: 'Mathematics',
        type: 'Full subject',
        inr: '₹3,499',
        aed: 'AED 154',
        usd: r'$ 42',
        isLive: true,
        usdOverridden: true),
    PricingItemModel(
        code: 'SCI',
        name: 'Science',
        type: 'Full subject',
        inr: '₹3,499',
        aed: 'AED 154',
        usd: r'$ 42',
        isLive: true),
    PricingItemModel(
        code: 'MOD',
        name: 'Trigonometry',
        type: 'Single module',
        inr: '₹699',
        aed: 'AED 31',
        usd: r'$ 8.5',
        isLive: false),
    PricingItemModel(
        code: 'MOD',
        name: 'Acids, Bases & Salts',
        type: 'Single module',
        inr: '₹699',
        aed: 'AED 31',
        usd: r'$ 8.5',
        isLive: true),
  ];

  void setSegment(int index) {
    planSegment = index;
    notifyListeners();
  }
}
