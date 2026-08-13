import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors AdminFeatureService's growth/insights methods —
/// `GET /admin/insights/*`. See [AdminDashboardService] for the separate
/// `/admin/analytics/*` group.
class AdminAnalyticsService {
  AdminAnalyticsService(this._apiClient);

  final ApiClient _apiClient;

  Future<InsightsOverviewModel> overview() async {
    final json = await _apiClient.get('/admin/insights/overview');
    return InsightsOverviewModel.fromJson(json as Map<String, dynamic>);
  }

  /// `visitors`/`trialStarts`/`conversionRate` are always null today — not
  /// instrumented on the backend yet. See [InsightsFunnelModel].
  Future<InsightsFunnelModel> funnel() async {
    final json = await _apiClient.get('/admin/insights/funnel');
    return InsightsFunnelModel.fromJson(json as Map<String, dynamic>);
  }

  Future<List<CourseInsightModel>> courses() async {
    final json = await _apiClient.get('/admin/insights/courses') as List<dynamic>;
    return json.map((e) => CourseInsightModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TeacherInsightModel>> teachers() async {
    final json = await _apiClient.get('/admin/insights/teachers') as List<dynamic>;
    return json.map((e) => TeacherInsightModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
