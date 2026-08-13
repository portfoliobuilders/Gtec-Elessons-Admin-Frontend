import '../../models/auth_session_model.dart';
import '../network/api_client.dart';

/// New access + refresh token pair from `POST /auth/refresh`. Deliberately
/// not [AuthSessionModel] — the refresh response has no `user` field, so
/// reusing that model would silently produce an empty user.
typedef TokenPair = ({String accessToken, String refreshToken});

/// Talks to the `/auth/*` endpoints and returns typed results.
class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      authenticated: false,
    );
    return AuthSessionModel.fromJson(json as Map<String, dynamic>);
  }

  /// `POST /auth/refresh` — the backend rotates refresh tokens (the one
  /// passed in is revoked and a new one is returned), so callers must
  /// persist both values from the result, not just the access token.
  Future<TokenPair> refresh(String refreshToken) async {
    final json = await _apiClient.post(
      '/auth/refresh',
      body: {'refreshToken': refreshToken},
      authenticated: false,
    ) as Map<String, dynamic>;
    return (
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
    );
  }

  /// `POST /auth/logout` — revokes the given refresh token server-side.
  Future<void> logout(String refreshToken) async {
    await _apiClient.post(
      '/auth/logout',
      body: {'refreshToken': refreshToken},
      authenticated: false,
    );
  }
}
