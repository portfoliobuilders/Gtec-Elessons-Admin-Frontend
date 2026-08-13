import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';

/// Thin JSON wrapper around [http] scoped to the G-TEC API base URL.
/// Screens/controllers/services never build URIs, decode bodies, or attach
/// tokens themselves — that all happens here.
///
/// Response shape varies per backend endpoint (bare object, bare array,
/// `{items,total}`, …) so `get`/`post`/… return the raw decoded JSON
/// (`dynamic`) — each service casts to the shape its endpoint actually
/// returns, per the backend contract, rather than this client guessing.
class ApiClient {
  ApiClient({
    http.Client? client,
    Future<String?> Function()? tokenGetter,
    Future<bool> Function()? onUnauthorized,
    void Function()? onSessionExpired,
  })  : _client = client ?? http.Client(),
        _tokenGetter = tokenGetter,
        _onUnauthorized = onUnauthorized,
        _onSessionExpired = onSessionExpired;

  static const String baseUrl = ApiConfig.baseUrl;

  final http.Client _client;

  /// Reads the current access token from storage. Injected rather than
  /// importing AuthStorage directly so this layer stays free of any
  /// Provider/controller dependency.
  final Future<String?> Function()? _tokenGetter;

  /// Attempts exactly one silent token refresh; returns whether it
  /// succeeded. Injected by whoever wires AuthService + AuthStorage
  /// together (see main.dart) so ApiClient never imports AuthService.
  final Future<bool> Function()? _onUnauthorized;

  /// Called once a request still fails auth after a refresh attempt (or no
  /// refresh is configured) — the caller should clear the session and
  /// return to login.
  final void Function()? _onSessionExpired;

  // Single-flight guard: the backend rotates refresh tokens (single use),
  // so two requests 401ing at the same moment must never trigger two
  // concurrent refresh calls — the second would consume an already-used
  // token and fail.
  Future<bool>? _refreshInFlight;

  Future<dynamic> get(String path, {String? token, bool authenticated = true}) =>
      _request('GET', path, token: token, authenticated: authenticated);

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
    bool authenticated = true,
  }) =>
      _request('POST', path, body: body, token: token, authenticated: authenticated);

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    String? token,
    bool authenticated = true,
  }) =>
      _request('PATCH', path, body: body, token: token, authenticated: authenticated);

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    String? token,
    bool authenticated = true,
  }) =>
      _request('PUT', path, body: body, token: token, authenticated: authenticated);

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    String? token,
    bool authenticated = true,
  }) =>
      _request('DELETE', path, body: body, token: token, authenticated: authenticated);

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
    bool authenticated = true,
  }) async {
    final String? resolvedToken = token ?? (authenticated ? await _tokenGetter?.call() : null);
    final response = await _send(method, path, body, resolvedToken);

    // Only attempt recovery for requests that actually carried a token —
    // an unauthenticated 401 (e.g. bad login credentials) is a normal error,
    // not an expired-session condition.
    if (response.statusCode == 401 && authenticated && resolvedToken != null && _onUnauthorized != null) {
      final bool refreshed = await _refreshOnce();
      if (refreshed) {
        final String? newToken = await _tokenGetter?.call();
        final retry = await _send(method, path, body, newToken);
        // The retry is still 401 (refresh "succeeded" but the new token is
        // no good either, or the account lost access mid-flight) — this is
        // as expired as the session gets. No further refresh attempt.
        if (retry.statusCode == 401) _onSessionExpired?.call();
        return _decode(retry);
      }
      _onSessionExpired?.call();
    }

    return _decode(response);
  }

  /// Coalesces concurrent 401s into a single refresh attempt.
  Future<bool> _refreshOnce() {
    return _refreshInFlight ??= _onUnauthorized!().whenComplete(() => _refreshInFlight = null);
  }

  Future<http.Response> _send(
    String method,
    String path,
    Map<String, dynamic>? body,
    String? token,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = _headers(token);
    try {
      switch (method) {
        case 'GET':
          return await _client.get(uri, headers: headers);
        case 'POST':
          return await _client.post(uri, headers: headers, body: jsonEncode(body ?? const {}));
        case 'PATCH':
          return await _client.patch(uri, headers: headers, body: jsonEncode(body ?? const {}));
        case 'PUT':
          return await _client.put(uri, headers: headers, body: jsonEncode(body ?? const {}));
        case 'DELETE':
          return await _client.delete(uri, headers: headers, body: body == null ? null : jsonEncode(body));
        default:
          throw ArgumentError('Unsupported method: $method');
      }
    } on SocketException {
      throw const ApiException('Could not reach the server. Check your connection and try again.');
    } on HttpException {
      throw const ApiException('Something went wrong. Please try again.');
    }
  }

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        // Free ngrok tunnels serve an HTML "you are about to visit…"
        // interstitial to any request that looks like it came from a
        // browser, which would otherwise break every call while pointed at
        // the dev backend. Harmless no-op against the production host.
        'ngrok-skip-browser-warning': 'true',
      };

  dynamic _decode(http.Response response) {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        // Non-JSON body (e.g. an HTML error page) — fall through with null.
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final Map<String, dynamic> errorBody = decoded is Map<String, dynamic> ? decoded : const {};
    throw ApiException(
      _readableMessage(errorBody, response.statusCode),
      statusCode: response.statusCode,
      rawBody: errorBody,
    );
  }

  /// Nest's ValidationPipe returns `message` as a `List<String>` for
  /// validation errors and a plain `String` otherwise — normalize both into
  /// one readable line.
  String _readableMessage(Map<String, dynamic> errorBody, int statusCode) {
    final dynamic message = errorBody['message'] ?? errorBody['error'];
    if (message is List) return message.map((e) => e.toString()).join('\n');
    return message?.toString() ?? 'Request failed ($statusCode).';
  }
}
