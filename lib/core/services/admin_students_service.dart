import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors AdminStudentsService. `list`/`detail` return different shapes —
/// see [StudentListItemModel]/[StudentDetailModel]'s doc comments.
class AdminStudentsService {
  AdminStudentsService(this._apiClient);

  final ApiClient _apiClient;

  Future<({int total, List<StudentListItemModel> students})> list({
    String? search,
    int take = 50,
    int skip = 0,
  }) async {
    final query = {
      if (search != null && search.isNotEmpty) 'search': search,
      'take': '$take',
      'skip': '$skip',
    };
    final path = '/admin/students?${Uri(queryParameters: query).query}';
    final json = await _apiClient.get(path) as Map<String, dynamic>;
    return (
      total: json['total'] as int? ?? 0,
      students: (json['students'] as List<dynamic>)
          .map((e) => StudentListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<StudentDetailModel> detail(String id) async {
    final json = await _apiClient.get('/admin/students/$id');
    return StudentDetailModel.fromJson(json as Map<String, dynamic>);
  }

  /// Backend rejects (403) modifying an ADMIN/SUPER_ADMIN target unless the
  /// caller is SUPER_ADMIN, and always rejects modifying your own account.
  Future<void> setStatus(String id, String status) async {
    await _apiClient.patch('/admin/students/$id/status', body: SetStudentStatusRequest(status).toJson());
  }

  /// `role` must be STUDENT | TEACHER | ADMIN — SUPER_ADMIN can never be
  /// granted through this endpoint.
  Future<void> setRole(String id, String role) async {
    await _apiClient.patch('/admin/students/$id/role', body: SetStudentRoleRequest(role).toJson());
  }
}
