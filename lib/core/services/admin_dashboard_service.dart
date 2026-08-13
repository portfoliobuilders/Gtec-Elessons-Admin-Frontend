import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors AdminAnalyticsService — `GET /admin/analytics/*`. Kept separate
/// from [AdminAnalyticsService] (which wraps the differently-shaped
/// `/admin/insights/*` growth endpoints — see that file's header comment).
class AdminDashboardService {
  AdminDashboardService(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardOverviewModel> overview() async {
    final json = await _apiClient.get('/admin/analytics/overview');
    return DashboardOverviewModel.fromJson(json as Map<String, dynamic>);
  }

  Future<List<TopCourseModel>> topCourses({int limit = 5}) async {
    final json = await _apiClient.get('/admin/analytics/top-courses?limit=$limit') as List<dynamic>;
    return json.map((e) => TopCourseModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<RecentOrderModel>> recentOrders({int limit = 10}) async {
    final json = await _apiClient.get('/admin/analytics/recent-orders?limit=$limit') as List<dynamic>;
    return json.map((e) => RecentOrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
