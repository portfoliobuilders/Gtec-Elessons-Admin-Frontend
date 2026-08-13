import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Broadcast (AdminFeatureService.broadcast) + notification template CRUD
/// (AdminConfigService) — grouped by frontend feature ("Notifications"),
/// even though the two live in different backend services.
class AdminNotificationService {
  AdminNotificationService(this._apiClient);

  final ApiClient _apiClient;

  /// Sends an in-app (+ best-effort push) notification to every student, or
  /// just those in one grade. Returns how many students it went to.
  Future<int> broadcast({required String title, required String body, String? gradeId}) async {
    final path = gradeId == null ? '/admin/broadcast' : '/admin/grades/$gradeId/broadcast';
    final json = await _apiClient.post(
      path,
      body: {'title': title, 'body': body, if (gradeId != null) 'gradeId': gradeId},
    ) as Map<String, dynamic>;
    return json['sent'] as int? ?? 0;
  }

  Future<List<NotificationTemplateModel>> listTemplates() async {
    final json = await _apiClient.get('/admin/notification-templates') as List<dynamic>;
    return json.map((e) => NotificationTemplateModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<NotificationTemplateModel> createTemplate(CreateNotificationTemplateRequest request) async {
    final json = await _apiClient.post('/admin/notification-templates', body: request.toJson());
    return NotificationTemplateModel.fromJson(json as Map<String, dynamic>);
  }

  Future<NotificationTemplateModel> updateTemplate(String type, UpdateNotificationTemplateRequest request) async {
    final json = await _apiClient.patch('/admin/notification-templates/$type', body: request.toJson());
    return NotificationTemplateModel.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteTemplate(String type) => _apiClient.delete('/admin/notification-templates/$type');
}
