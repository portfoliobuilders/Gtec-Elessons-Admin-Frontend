import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors AdminFeatureService's review methods.
class AdminReviewService {
  AdminReviewService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AdminReviewModel>> list() async {
    final json = await _apiClient.get('/admin/reviews') as List<dynamic>;
    return json.map((e) => AdminReviewModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminReviewModel> create(CreateReviewRequest request) async {
    final json = await _apiClient.post('/admin/reviews', body: request.toJson());
    return AdminReviewModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminReviewModel> approve(String id, bool isApproved) async {
    final json = await _apiClient.patch('/admin/reviews/$id/approve', body: {'isApproved': isApproved});
    return AdminReviewModel.fromJson(json as Map<String, dynamic>);
  }
}
