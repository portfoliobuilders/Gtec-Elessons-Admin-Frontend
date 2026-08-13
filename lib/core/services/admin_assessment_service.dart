import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors AssessmentsService's admin methods. Routes live on
/// AssessmentsController (not AdminController) but are still `/admin/*` and
/// ADMIN/SUPER_ADMIN/TEACHER-gated.
class AdminAssessmentService {
  AdminAssessmentService(this._apiClient);

  final ApiClient _apiClient;

  /// TEACHER sees only assessments tied to a subject they teach;
  /// ADMIN/SUPER_ADMIN gets everything.
  Future<List<AdminAssessmentListItemModel>> list() async {
    final json = await _apiClient.get('/admin/assessments') as List<dynamic>;
    return json.map((e) => AdminAssessmentListItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminAssessmentDetailModel> detail(String id) async {
    final json = await _apiClient.get('/admin/assessments/$id');
    return AdminAssessmentDetailModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminAssessmentDetailModel> create(CreateAssessmentRequest request) async {
    final json = await _apiClient.post('/admin/assessments', body: request.toJson());
    return AdminAssessmentDetailModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminAssessmentDetailModel> createForGrade(String gradeId, CreateAssessmentRequest request) async {
    final json = await _apiClient.post('/admin/grades/$gradeId/assessments', body: request.toJson());
    return AdminAssessmentDetailModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminAssessmentDetailModel> createForSubject(String subjectId, CreateAssessmentRequest request) async {
    final json = await _apiClient.post('/admin/subjects/$subjectId/assessments', body: request.toJson());
    return AdminAssessmentDetailModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminAssessmentDetailModel> createForChapter(String chapterId, CreateAssessmentRequest request) async {
    final json = await _apiClient.post('/admin/chapters/$chapterId/assessments', body: request.toJson());
    return AdminAssessmentDetailModel.fromJson(json as Map<String, dynamic>);
  }

  Future<QuestionModel> addQuestion(String assessmentId, AddQuestionRequest request) async {
    final json = await _apiClient.post('/admin/assessments/$assessmentId/questions', body: request.toJson());
    return QuestionModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminAssessmentListItemModel> publish(String id, bool isPublished) async {
    final json = await _apiClient.patch('/admin/assessments/$id/publish', body: {'isPublished': isPublished});
    return AdminAssessmentListItemModel.fromJson(json as Map<String, dynamic>);
  }
}
