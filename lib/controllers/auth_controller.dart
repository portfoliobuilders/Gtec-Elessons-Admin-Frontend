import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/services/auth_service.dart';
import '../core/services/auth_storage.dart';
import '../models/user_model.dart';

enum AuthStatus { unknown, authenticating, authenticated, unauthenticated }

/// Owns the signed-in session: login, logout, and the restart-time check
/// against the persisted token (see [restoreSession]).
class AuthController extends ChangeNotifier {
  AuthController({AuthService? authService, AuthStorage? authStorage})
      : _authService = authService ?? AuthService(),
        _authStorage = authStorage ?? AuthStorage();

  final AuthService _authService;
  final AuthStorage _authStorage;

  AuthStatus status = AuthStatus.unknown;
  UserModel? user;
  String? errorMessage;

  bool get isLoading => status == AuthStatus.authenticating;

  /// Called once at startup to see if a previous session is still stored.
  Future<void> restoreSession() async {
    final session = await _authStorage.read();
    if (session == null) {
      status = AuthStatus.unauthenticated;
    } else {
      user = session.user;
      status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    status = AuthStatus.authenticating;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await _authService.login(email: email, password: password);
      await _authStorage.save(session);
      user = session.user;
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// [callBackend] is false when called from ApiClient's session-expired
  /// path — a refresh has already just failed there, so the stored refresh
  /// token is known-invalid and there's nothing useful left to revoke.
  Future<void> logout({bool callBackend = true}) async {
    if (callBackend) {
      final refreshToken = await _authStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _authService.logout(refreshToken);
        } catch (_) {
          // Best-effort — the user must be able to log out locally even if
          // the backend call fails (offline, server error, etc.).
        }
      }
    }
    await _authStorage.clear();
    user = null;
    errorMessage = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
