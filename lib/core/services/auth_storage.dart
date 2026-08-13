import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auth_session_model.dart';
import '../../models/user_model.dart';

/// Persists the signed-in session so it survives app restarts.
class AuthStorage {
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _userKey = 'auth_user';

  Future<void> save(AuthSessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, session.accessToken);
    await prefs.setString(_refreshTokenKey, session.refreshToken);
    await prefs.setString(_userKey, jsonEncode(session.user.toJson()));
  }

  /// Updates just the token pair (e.g. after a `/auth/refresh` call) —
  /// leaves the cached user untouched, since the refresh response doesn't
  /// include one.
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<AuthSessionModel?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString(_accessTokenKey);
    final String? userJson = prefs.getString(_userKey);
    if (accessToken == null || userJson == null) return null;

    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: prefs.getString(_refreshTokenKey) ?? '',
      user: UserModel.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      ),
    );
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }
}
