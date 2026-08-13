import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors LiveService's admin/teacher methods.
///
/// IMPORTANT: no `list()` here on purpose — the backend has no
/// `GET /admin/live-classes`. See [AdminLiveClassModel]'s doc comment.
class AdminLiveClassService {
  AdminLiveClassService(this._apiClient);

  final ApiClient _apiClient;

  Future<AdminLiveClassModel> create(CreateLiveClassRequest request) async {
    final json = await _apiClient.post('/admin/live-classes', body: request.toJson());
    return AdminLiveClassModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminLiveClassModel> createForSubject(String subjectId, CreateLiveClassRequest request) async {
    final json = await _apiClient.post('/admin/subjects/$subjectId/live-classes', body: request.toJson());
    return AdminLiveClassModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminLiveClassModel> createForGrade(String gradeId, CreateLiveClassRequest request) async {
    final json = await _apiClient.post('/admin/grades/$gradeId/live-classes', body: request.toJson());
    return AdminLiveClassModel.fromJson(json as Map<String, dynamic>);
  }

  /// `status` must be one of: SCHEDULED | LIVE | ENDED | CANCELLED.
  Future<AdminLiveClassModel> setStatus(String id, String status) async {
    final json = await _apiClient.post('/admin/live-classes/$id/status', body: {'status': status});
    return AdminLiveClassModel.fromJson(json as Map<String, dynamic>);
  }
}
