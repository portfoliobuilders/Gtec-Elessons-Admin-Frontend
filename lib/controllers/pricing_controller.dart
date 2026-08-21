import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/services/admin_pricing_service.dart';
import '../models/admin/admin_models.dart';

enum PricingLoadStatus { initial, loading, loaded, error }

/// Global Pricing (Phase 9) — the central "what do we sell" overview, backed
/// by the exact same `AdminPricingService`/`AdminProductModel`/
/// `AdminProductPriceModel`/request types Curriculum's per-Grade/Subject/
/// Chapter pricing already uses (see CurriculumController.findProductFor
/// and regional_pricing_section.dart) — one backend contract, two entry
/// points, no separate pricing API or local pricing database.
class PricingController extends ChangeNotifier {
  PricingController(this._service);

  final AdminPricingService _service;

  // ── Products ─────────────────────────────────────────────────────────────

  PricingLoadStatus status = PricingLoadStatus.initial;
  String? error;
  List<AdminProductModel> products = [];

  /// Both client-side only — confirmed live that `GET /admin/pricing`
  /// silently ignores `?search=`/`?type=` (still returns every product
  /// regardless), so these filter the already-loaded list instead.
  String search = '';
  String? typeFilter;

  bool get isLoading => status == PricingLoadStatus.loading;

  List<AdminProductModel> get filteredProducts {
    var list = products;
    if (typeFilter != null) list = [for (final p in list) if (p.type == typeFilter) p];
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) list = [for (final p in list) if (p.title.toLowerCase().contains(q)) p];
    return list;
  }

  Future<void> loadProducts() async {
    status = PricingLoadStatus.loading;
    error = null;
    notifyListeners();
    try {
      products = await _service.list();
      status = PricingLoadStatus.loaded;
    } on ApiException catch (e) {
      error = e.message;
      status = PricingLoadStatus.error;
    } catch (_) {
      error = 'Unable to load pricing. Please try again.';
      status = PricingLoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshProducts() => loadProducts();

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  void setTypeFilter(String? value) {
    typeFilter = value;
    notifyListeners();
  }

  // ── Selected product (for the product-pricing detail view) ─────────────

  String? selectedProductId;

  static const _emptyProduct = AdminProductModel(id: '', type: 'SUBJECT', format: 'RECORDED', title: '');

  AdminProductModel get selectedProduct =>
      products.firstWhere((p) => p.id == selectedProductId, orElse: () => _emptyProduct);

  void selectProduct(String id) {
    selectedProductId = id;
    notifyListeners();
  }

  void clearSelectedProduct() {
    selectedProductId = null;
    notifyListeners();
  }

  // ── Regional price CRUD ──────────────────────────────────────────────────
  // Same three endpoints Curriculum's RegionalPricingSection reconciliation
  // calls (POST/PATCH/DELETE /admin/pricing/products/:id/prices[/:priceId]).
  // Each call patches [products] in place from the real response — since
  // both this page and Curriculum's edit forms always re-fetch from
  // `GET /admin/pricing` on open, there is no separate cached copy to drift
  // out of sync.

  String? priceError;

  Future<bool> createRegionalPrice(String productId, CreatePriceRequest request) async {
    try {
      final created = await _service.createProductPrice(productId, request);
      _patchPrices(productId, (prices) => [...prices, created]);
      priceError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      priceError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRegionalPrice(String productId, String priceId, UpdateProductPriceRequest request) async {
    try {
      final updated = await _service.updateProductPrice(productId, priceId, request);
      _patchPrices(productId, (prices) => [for (final p in prices) p.priceId == priceId ? updated : p]);
      priceError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      priceError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRegionalPrice(String productId, String priceId) async {
    try {
      await _service.deleteProductPrice(productId, priceId);
      _patchPrices(productId, (prices) => [for (final p in prices) if (p.priceId != priceId) p]);
      priceError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      priceError = e.message;
      notifyListeners();
      return false;
    }
  }

  void _patchPrices(
    String productId,
    List<AdminProductPriceModel> Function(List<AdminProductPriceModel> current) transform,
  ) {
    products = [
      for (final p in products)
        if (p.id == productId) p.copyWith(prices: transform(p.prices)) else p,
    ];
  }
}
