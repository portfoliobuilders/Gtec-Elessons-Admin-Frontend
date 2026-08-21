import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/services/admin_orders_service.dart';
import '../models/admin/admin_models.dart';

enum OrdersLoadStatus { initial, loading, loaded, error }

/// Order Management (Phase 7A) — real roster backed by
/// `GET /admin/orders`/`GET /admin/orders/:id` via [AdminOrdersService].
/// Phase 7B adds the one supported mutation — refund — nothing else
/// (no status/amount/customer edits).
class OrdersController extends ChangeNotifier {
  OrdersController(this._service);

  final AdminOrdersService _service;

  // ── List ─────────────────────────────────────────────────────────────────

  OrdersLoadStatus status = OrdersLoadStatus.initial;
  String? error;
  List<AdminOrderListItemModel> orders = [];
  int total = 0;

  /// `status` (when set) is a real server-side filter — confirmed live
  /// against `GET /admin/orders?status=`. Null = All.
  String? statusFilter;

  /// Client-side only — confirmed live that `?search=` on this endpoint is
  /// silently ignored (unlike `/admin/students`), so this filters the
  /// already-loaded page instead of hitting the API again.
  String searchQuery = '';

  bool get isLoading => status == OrdersLoadStatus.loading;

  List<AdminOrderListItemModel> get filteredOrders {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return orders;
    return [
      for (final o in orders)
        if (o.orderNumber.toLowerCase().contains(q) ||
            (o.userName?.toLowerCase().contains(q) ?? false) ||
            (o.userEmail?.toLowerCase().contains(q) ?? false) ||
            (o.billingName?.toLowerCase().contains(q) ?? false))
          o,
    ];
  }

  Future<void> loadOrders() async {
    status = OrdersLoadStatus.loading;
    error = null;
    notifyListeners();
    try {
      final result = await _service.list(status: statusFilter);
      orders = result.orders;
      total = result.total;
      status = OrdersLoadStatus.loaded;
    } on ApiException catch (e) {
      error = e.message;
      status = OrdersLoadStatus.error;
    } catch (_) {
      error = 'Unable to load orders. Please try again.';
      status = OrdersLoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshOrders() => loadOrders();

  void setStatusFilter(String? value) {
    if (statusFilter == value) return;
    statusFilter = value;
    loadOrders();
  }

  void setSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  // ── Status breakdown (KPI row) ──────────────────────────────────────────
  // Real per-status counts for the "Payments & Leads" KPI cards — each
  // backend `list()` call already returns a real `total` for its filter, so
  // four minimal (`take: 1`) requests give accurate counts without loading
  // every order. Kept separate from `orders`/`total` above, which reflect
  // whatever single status filter the table itself is currently showing.
  Map<String, int> statusCounts = {};

  Future<void> loadStatusCounts() async {
    try {
      const statuses = ['PENDING', 'PAID', 'FAILED', 'REFUNDED'];
      final results = await Future.wait([for (final s in statuses) _service.list(status: s, take: 1)]);
      statusCounts = {for (var i = 0; i < statuses.length; i++) statuses[i]: results[i].total};
    } catch (_) {
      // Best-effort supplementary view — leave whatever was last loaded (or
      // empty, showing "—") rather than blocking/erroring the whole page.
    }
    notifyListeners();
  }

  // ── Detail ───────────────────────────────────────────────────────────────

  OrdersLoadStatus detailStatus = OrdersLoadStatus.initial;
  String? detailError;
  AdminOrderDetailModel? selectedOrder;

  bool get isDetailLoading => detailStatus == OrdersLoadStatus.loading;

  Future<void> loadOrder(String id) async {
    detailStatus = OrdersLoadStatus.loading;
    detailError = null;
    notifyListeners();
    try {
      selectedOrder = await _service.detail(id);
      detailStatus = OrdersLoadStatus.loaded;
    } on ApiException catch (e) {
      detailError = e.message;
      detailStatus = OrdersLoadStatus.error;
    } catch (_) {
      detailError = 'Unable to load order. Please try again.';
      detailStatus = OrdersLoadStatus.error;
    }
    notifyListeners();
  }

  // ── Refund (Phase 7B) ────────────────────────────────────────────────────
  // Only mutation this phase. `AdminOrdersService.refund()` already existed
  // (Phase 2) and was confirmed live: the backend rejects anything but a
  // PAID order with 400 "Only a PAID order can be refunded" — [canRefund]
  // mirrors that exactly so the button is never shown/enabled where the
  // backend would reject it anyway.

  String? refundError;

  bool canRefund(AdminOrderDetailModel order) => order.status == 'PAID';

  /// On success, patches [selectedOrder] from the refund response (a full
  /// [AdminOrderDetailModel] — confirmed same shape as `detail()`, so no
  /// extra `GET` is needed) and the matching row in [orders] — never a full
  /// list reload. On failure, nothing local changes; [refundError] carries
  /// the real backend message.
  Future<bool> refundOrder(String id, {String? reason}) async {
    try {
      final result = await _service.refund(id, reason: reason);
      if (selectedOrder?.id == id) {
        // The refund response omits `user` entirely (see
        // AdminOrderDetailModel's doc comment) — carry the already-known
        // customer fields through rather than lose them.
        selectedOrder = result.copyWith(
          userId: result.userId ?? selectedOrder!.userId,
          userName: result.userName ?? selectedOrder!.userName,
          userEmail: result.userEmail ?? selectedOrder!.userEmail,
          userPhone: result.userPhone ?? selectedOrder!.userPhone,
        );
      }
      orders = [for (final o in orders) o.id == id ? o.copyWith(status: result.status) : o];
      refundError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      refundError = e.message;
      notifyListeners();
      return false;
    }
  }
}
