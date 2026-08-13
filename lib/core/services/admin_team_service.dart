import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors AdminFeatureService's team-invite methods, plus the generic user
/// listing used as the Team roster (there's no dedicated roster endpoint —
/// see [UserListItemModel]'s doc comment for the caveat on who can call it).
class AdminTeamService {
  AdminTeamService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TeamInviteModel>> listInvites() async {
    final json = await _apiClient.get('/admin/team-invites') as List<dynamic>;
    return json.map((e) => TeamInviteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TeamInviteModel> createInvite(CreateTeamInviteRequest request) async {
    final json = await _apiClient.post('/admin/team-invites', body: request.toJson());
    return TeamInviteModel.fromJson(json as Map<String, dynamic>);
  }

  /// `role` must be ADMIN or TEACHER — the current roster, filtered
  /// server-side to active users of that role.
  Future<({int total, List<UserListItemModel> users})> roster({
    required String role,
    String? search,
    int take = 50,
    int skip = 0,
  }) async {
    final query = {
      'role': role,
      if (search != null && search.isNotEmpty) 'search': search,
      'take': '$take',
      'skip': '$skip',
    };
    final path = '/me/users?${Uri(queryParameters: query).query}';
    final json = await _apiClient.get(path) as Map<String, dynamic>;
    return (
      total: json['total'] as int? ?? 0,
      users: (json['users'] as List<dynamic>).map((e) => UserListItemModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
