import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/services/admin_dashboard_service.dart';
import '../models/admin/admin_models.dart';

enum DashboardLoadStatus { initial, loading, loaded, error }

/// Dashboard — KPIs, enrollment trend, revenue by currency, top courses,
/// recent orders. All real data from `GET /admin/analytics/*` via
/// [AdminDashboardService]; no hardcoded/mock values.
class DashboardController extends ChangeNotifier {
  DashboardController(this._service);

  final AdminDashboardService _service;

  DashboardLoadStatus status = DashboardLoadStatus.initial;
  String? error;

  bool get isLoading => status == DashboardLoadStatus.loading;

  DashboardOverviewModel? overview;
  List<TopCourseModel> topCourses = [];
  List<RecentOrderModel> recentOrders = [];

  /// Loads overview, top courses, and recent orders in parallel — they're
  /// independent requests, no reason to serialize them.
  Future<void> load() async {
    status = DashboardLoadStatus.loading;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.overview(),
        _service.topCourses(limit: 5),
        _service.recentOrders(limit: 8),
      ]);
      overview = results[0] as DashboardOverviewModel;
      topCourses = results[1] as List<TopCourseModel>;
      recentOrders = results[2] as List<RecentOrderModel>;
      status = DashboardLoadStatus.loaded;
    } on ApiException catch (e) {
      error = e.message;
      status = DashboardLoadStatus.error;
    } catch (_) {
      error = 'Unable to load dashboard data. Please try again.';
      status = DashboardLoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => load();
}
