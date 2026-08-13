import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors AdminFeatureService's assignment/submission/grading methods.
class AdminAssignmentService {
  AdminAssignmentService(this._apiClient);

  final ApiClient _apiClient;

  /// TEACHER sees only assignments tied to subjects they teach;
  /// ADMIN/SUPER_ADMIN gets the full queue.
  Future<List<AssignmentModel>> list() async {
    final json = await _apiClient.get('/admin/assignments') as List<dynamic>;
    return json.map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AssignmentModel> create(CreateAssignmentRequest request) async {
    final json = await _apiClient.post('/admin/assignments', body: request.toJson());
    return AssignmentModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AssignmentModel> createForSubject(String subjectId, CreateAssignmentRequest request) async {
    final json = await _apiClient.post('/admin/subjects/$subjectId/assignments', body: request.toJson());
    return AssignmentModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AssignmentModel> update(String id, UpdateAssignmentRequest request) async {
    final json = await _apiClient.patch('/admin/assignments/$id', body: request.toJson());
    return AssignmentModel.fromJson(json as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _apiClient.delete('/admin/assignments/$id');

  /// TEACHER may only view submissions for assignments under a subject they
  /// teach; ADMIN/SUPER_ADMIN are unrestricted.
  Future<List<AssignmentSubmissionModel>> listSubmissions(String assignmentId) async {
    final json = await _apiClient.get('/admin/assignments/$assignmentId/submissions') as List<dynamic>;
    return json.map((e) => AssignmentSubmissionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AssignmentSubmissionModel> gradeSubmission(String submissionId, GradeSubmissionRequest request) async {
    final json = await _apiClient.patch('/admin/assignments/submissions/$submissionId/grade', body: request.toJson());
    return AssignmentSubmissionModel.fromJson(json as Map<String, dynamic>);
  }
}
