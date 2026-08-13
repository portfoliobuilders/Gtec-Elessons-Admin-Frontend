import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors AdminEnrollmentsService — currently just the one manual-grant
/// endpoint (no list/revoke endpoint exists on the backend yet).
class AdminEnrollmentsService {
  AdminEnrollmentsService(this._apiClient);

  final ApiClient _apiClient;

  /// `POST /admin/students/:studentId/subjects/:subjectId/enrollments` —
  /// grants (or renews, if one already exists) a student's access to a
  /// subject. Creates a hidden inactive Product behind the scenes if the
  /// subject never had one.
  Future<GrantEnrollmentResultModel> grantSubject({required String studentId, required String subjectId}) async {
    final json = await _apiClient.post('/admin/students/$studentId/subjects/$subjectId/enrollments');
    return GrantEnrollmentResultModel.fromJson(json as Map<String, dynamic>);
  }
}
